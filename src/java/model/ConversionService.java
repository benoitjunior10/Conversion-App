package model;

import java.io.File;
import java.util.UUID;
import com.aspose.pdf.SaveFormat;

/**
 *  - PDF -> Word
 *  - Word -> PDF
 *  - PDF -> Excel
 */
public class ConversionService {

    public static class ConversionResult {
        public final File outputFile;     // fichier final (docx/pdf/xlsx)
        public final File previewPdf;     // aperçu en PDF (peut etre null)
        public ConversionResult(File outputFile, File previewPdf){
            this.outputFile = outputFile;
            this.previewPdf = previewPdf;
        }
    }

    private static String baseNameWithoutExt(String name){
        int dot = name.lastIndexOf('.');
        return (dot > 0) ? name.substring(0, dot) : name;
    }

    private static String safeExt(String filename){
        int dot = filename.lastIndexOf('.');
        return (dot > 0) ? filename.substring(dot + 1).toLowerCase() : "";
    }

    private static String unique(String prefix){
        String shortId = UUID.randomUUID().toString().replace("-", "").substring(0, 8); // 8 caractères
        return prefix + "-" + shortId;
    }


   public ConversionResult convert(File inputFile, String mode) throws Exception {
       String originalName = inputFile.getName();
       String base = baseNameWithoutExt(originalName);
       File outDir = inputFile.getParentFile();

       switch (mode) {
           case "WORD_TO_PDF": {
               // Word -> PDF
               File out = new File(outDir, unique(base) + ".pdf");
               com.aspose.words.Document doc = new com.aspose.words.Document(inputFile.getAbsolutePath());
               doc.save(out.getAbsolutePath(), com.aspose.words.SaveFormat.PDF);
               // Aperçu = le PDF lui-même
               return new ConversionResult(out, out);
           }

           case "PDF_TO_WORD": {
               // PDF -> Word (DOCX)
               File out = new File(outDir, unique(base) + ".docx");
               com.aspose.pdf.Document pdf = new com.aspose.pdf.Document(inputFile.getAbsolutePath());
               pdf.save(out.getAbsolutePath(), SaveFormat.DocX);

               // Aperçu : on tente de convertir le DOCX en PDF avec Aspose.Words
               File preview = new File(outDir, unique(base) + "-preview.pdf");
               try {
                   com.aspose.words.Document docx = new com.aspose.words.Document(out.getAbsolutePath());
                   docx.save(preview.getAbsolutePath(), com.aspose.words.SaveFormat.PDF);
                   return new ConversionResult(out, preview);
               } catch (Throwable t){
                   // si Aspose.Words n'est pas bien configuré, on garde juste le fichier final
                   return new ConversionResult(out, null);
               }
           }

           case "PDF_TO_EXCEL": {
               // PDF -> Excel (XLSX)
               File out = new File(outDir, unique(base) + ".xlsx");
               com.aspose.pdf.Document pdf = new com.aspose.pdf.Document(inputFile.getAbsolutePath());
               pdf.save(out.getAbsolutePath(), SaveFormat.Excel);

               // Aperçu : on tente XLSX -> PDF via Aspose.Cells (si jar présent)
               File preview = new File(outDir, unique(base) + "-preview.pdf");
               try {
                   com.aspose.cells.Workbook wb = new com.aspose.cells.Workbook(out.getAbsolutePath());
                   wb.save(preview.getAbsolutePath(), com.aspose.cells.SaveFormat.PDF);
                   return new ConversionResult(out, preview);
               } catch (Throwable t){
                   return new ConversionResult(out, null);
               }
           }

           default:
               throw new IllegalArgumentException("Mode inconnu: " + mode);
       }
   }
    



    public static String guessMimeType(File file){
        String ext = safeExt(file.getName());
        switch (ext){
            case "pdf": return "application/pdf";
            case "doc": return "application/msword";
            case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls": return "application/vnd.ms-excel";
            case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            default: return "application/octet-stream";
        }
    }
}
