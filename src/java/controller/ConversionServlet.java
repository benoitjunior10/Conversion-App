package controller;

import model.ConversionService;
import model.ConversionService.ConversionResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 *  - POST /convert  -> upload + conversion + forward result.jsp
 *  - GET  /download -> télécharge le fichier final
 *  - GET  /preview  -> affiche l'aperçu PDF 
 */
@WebServlet(urlPatterns = {"/convert", "/download", "/preview"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,   // 2MB
        maxFileSize = 1024 * 1024 * 50,        // 50MB
        maxRequestSize = 1024 * 1024 * 60      // 60MB
)
public class ConversionServlet extends HttpServlet {

    private final ConversionService service = new ConversionService();

    private File getBaseTempDir() throws IOException {
        File base = new File(System.getProperty("java.io.tmpdir"), "doc-converter");
        if (!base.exists()) Files.createDirectories(base.toPath());
        return base;
    }

    private static class Stored {
        final File output;
        final File previewPdf; // peut être null
        Stored(File output, File previewPdf){
            this.output = output;
            this.previewPdf = previewPdf;
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Stored> getStore(HttpSession session){
        Object o = session.getAttribute("STORE");
        if (o instanceof Map) return (Map<String, Stored>) o;
        Map<String, Stored> store = new HashMap<>();
        session.setAttribute("STORE", store);
        return store;
    }

    private static String safeFileName(String submitted){
        if (submitted == null) return "file";
        // évite les chemins (Windows, etc.)
        submitted = submitted.replace("\\", "/");
        int idx = submitted.lastIndexOf('/');
        return (idx >= 0) ? submitted.substring(idx + 1) : submitted;
    }

    private static String extLower(String file){
        int dot = file.lastIndexOf('.');
        return (dot > 0) ? file.substring(dot + 1).toLowerCase() : "";
    }

    private static boolean isAllowed(String mode, String ext){
        if ("WORD_TO_PDF".equals(mode)) {
            return ext.equals("doc") || ext.equals("docx");
        }
        if ("PDF_TO_WORD".equals(mode) || "PDF_TO_EXCEL".equals(mode)) {
            return ext.equals("pdf");
        }
        return false;
    }
    

    private static boolean isSupportedFormat(String ext) {
    
        return ext.equals("pdf") || ext.equals("doc") || ext.equals("docx") || ext.equals("xls") || ext.equals("xlsx");
    }
    
    private static String buildAbsoluteUrl(HttpServletRequest req, String relative){
        // ex: http://localhost:8080/App/download?token=...
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String ctx = req.getContextPath();

        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && port == 80) || ("https".equalsIgnoreCase(scheme) && port == 443);
        String base = scheme + "://" + host + (defaultPort ? "" : (":" + port)) + ctx;
        if (!relative.startsWith("/")) relative = "/" + relative;
        return base + relative;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!request.getServletPath().equals("/convert")) {
            response.sendError(405);
            return;
        }

        String mode = request.getParameter("mode");
        Part part = request.getPart("file");

        if (mode == null || part == null || part.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Fichier ou mode manquant.");
            return;
        }

        String submitted = safeFileName(part.getSubmittedFileName());
        String ext = extLower(submitted);

        if (!isAllowed(mode, ext)) {
            String msg;
            if (!isSupportedFormat(ext)) {
                msg = "Le format de fichier ." + ext + " n'est pas pris en charge. Seuls les formats PDF, DOC, DOCX, XLS et XLSX sont acceptés.";
            } else {
                msg = "Vous essayez de convertir un fichier ." + ext + " avec le mode " + mode + ". Veuillez changer le mode de conversion.";
            }
            request.setAttribute("errorMessage", msg);
            // garde le mode choisi pour éviter de le réinitialiser dans le select
            request.setAttribute("previousMode", mode); 
            // On renvoie vers la page d'accueil
            request.getRequestDispatcher("index.jsp").forward(request, response);
            return;
        }

        // Dossier temp unique pour cette conversion
        File jobDir = new File(getBaseTempDir(), "job-" + UUID.randomUUID().toString().replace("-", ""));
        Files.createDirectories(jobDir.toPath());

        File input = new File(jobDir, submitted);
        part.write(input.getAbsolutePath());

        try {
            ConversionResult result = service.convert(input, mode);

            // stocker en session (token -> fichier)
            String token = UUID.randomUUID().toString().replace("-", "");
            getStore(request.getSession()).put(token, new Stored(result.outputFile, result.previewPdf));

            String downloadRel = "/download?token=" + token;
            String previewRel  = "/preview?token=" + token;

            String downloadLink = request.getContextPath() + downloadRel;
            String previewLink  = request.getContextPath() + previewRel;
            String fullDownload = buildAbsoluteUrl(request, downloadRel);

            String shareText = "Voici le document converti : " + fullDownload;

            request.setAttribute("token", token);
            request.setAttribute("fileName", result.outputFile.getName());
            request.setAttribute("downloadLink", downloadLink);
            request.setAttribute("previewLink", previewLink);
            request.setAttribute("shareLink", fullDownload);
            request.setAttribute("shareText", shareText);
            request.setAttribute("previewAvailable", result.previewPdf != null);

            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la conversion : " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token == null || token.isBlank()) {
            response.sendError(400, "token manquant");
            return;
        }

        Stored stored = getStore(request.getSession()).get(token);
        if (stored == null) {
            response.sendError(404, "Fichier introuvable ou session expirée");
            return;
        }

        String path = request.getServletPath();
        if ("/download".equals(path)) {
            streamFile(response, stored.output, true);
        } else if ("/preview".equals(path)) {
            if (stored.previewPdf == null) {
                response.sendError(404, "Aperçu indisponible");
                return;
            }
            streamFile(response, stored.previewPdf, false);
        } else {
            response.sendError(404);
        }
    }

    private static void streamFile(HttpServletResponse response, File file, boolean attachment) throws IOException {
        if (file == null || !file.exists()) {
            response.sendError(404);
            return;
        }

        String mime = ConversionService.guessMimeType(file);
        response.setContentType(mime);
        response.setHeader("X-Content-Type-Options", "nosniff");

        String disposition = (attachment ? "attachment" : "inline") + "; filename=\"" + file.getName().replace("\"", "") + "\"";
        response.setHeader("Content-Disposition", disposition);
        response.setContentLengthLong(file.length());

        try (FileInputStream in = new FileInputStream(file); OutputStream out = response.getOutputStream()) {
            in.transferTo(out);
            out.flush();
        }
    }
}
