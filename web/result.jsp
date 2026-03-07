<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- 
   On s'assure que les variables sont null-safe 
   token, fileName, downloadLink, previewLink, shareLink, shareText, previewAvailable
--%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Convertisseur - Résultat</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="style.css">
    
    <script>
        const CONFIG = {
            shareText: "${requestScope.shareText}",
            shareLink: "${requestScope.shareLink}",
            previewUrl: "${requestScope.previewAvailable ? requestScope.previewLink : ''}"
        };
    </script>
</head>
<body class="page-result">

    <header class="navbar sticky-header bg-white-nav">
        <div class="logo">
            <span class="material-symbols-outlined logo-icon-blue">sync_alt</span>
            <span class="logo-text">Convertisseur</span>
        </div>
        <nav class="nav-links">
            <a href="index.jsp">Convertir</a>
            <a href="#">Outils PDF</a>
        </nav>
        <div class="nav-auth">
            <button class="btn btn-primary">Mon Compte</button>
        </div>
    </header>

    <main class="result-layout">
        <aside class="sidebar">
            <div class="success-card">
                <div class="success-icon-large">
                    <span class="material-symbols-outlined">check_circle</span>
                </div>
                <h1>Conversion terminée !</h1>
                <p class="desc">Votre fichier a été converti avec succès. Il est prêt à être téléchargé.</p>

                <div class="file-summary">
                    <div class="file-icon-red">
                        <span class="material-symbols-outlined">description</span>
                    </div>
                    <div class="file-info">
                        <span class="filename">${requestScope.fileName}</span>
                        <span class="filesize">Prêt au téléchargement</span>
                    </div>
                    <span class="material-symbols-outlined check-green" style="color:#22C55E">check</span>
                </div>

                <a href="${requestScope.downloadLink}" class="btn btn-blue-full" style="text-decoration:none;">
                    <span class="material-symbols-outlined">download</span> Télécharger
                </a>
            </div>

            <div class="action-list">
                <div class="action-item" id="copyLinkBtn">
                    <div class="action-left">
                        <span class="material-symbols-outlined">link</span>
                        <span>Copier le lien de partage</span>
                    </div>
                    <span class="material-symbols-outlined chevron">chevron_right</span>
                </div>
                <a href="index.jsp" class="action-item" style="text-decoration:none; color:inherit;">
                    <div class="action-left">
                        <span class="material-symbols-outlined">cached</span>
                        <span>Convertir un autre fichier</span>
                    </div>
                    <span class="material-symbols-outlined chevron">chevron_right</span>
                </a>
                <div class="action-item" onclick="window.location.href='mailto:?subject=Fichier converti&body=${requestScope.shareText}'">
                    <div class="action-left">
                        <span class="material-symbols-outlined">mail</span>
                        <span>Envoyer par email</span>
                    </div>
                    <span class="material-symbols-outlined chevron">chevron_right</span>
                </div>
            </div>
        </aside>

        <section class="preview-area">
            <div class="toolbar">
                <div class="tool-group left">
                    <span class="label">Aperçu</span>
                    <span class="badge">Lecture seule</span>
                </div>
                <div class="tool-group right">
                    <button class="icon-btn" onclick="document.querySelector('iframe').contentWindow.print()"><span class="material-symbols-outlined">print</span></button>
                </div>
            </div>

            <div class="document-viewer" id="docViewerContainer">
                <%-- Logique d'affichage de l'aperçu --%>
                <% 
                   Object previewAvailable = request.getAttribute("previewAvailable");
                   if (previewAvailable != null && (Boolean)previewAvailable) { 
                %>
                    <iframe src="${requestScope.previewLink}#toolbar=0" width="100%" height="100%" style="border:none; border-radius:12px; min-height:600px;"></iframe>
                <% } else { %>
                    <div class="doc-page">
                        <div class="doc-header">
                            <div class="doc-line title"></div>
                            <div class="doc-line date"></div>
                        </div>
                        <hr class="doc-divider">
                        <div class="doc-paragraphs">
                            <div class="doc-line full"></div>
                            <div class="doc-line full"></div>
                            <div class="doc-line short"></div>
                        </div>
                        <div class="doc-paragraphs center" style="text-align:center; padding-top:40px; color:#64748B;">
                            <p>Aperçu non disponible pour ce format.</p>
                            <p>Veuillez télécharger le fichier.</p>
                        </div>
                    </div>
                <% } %>
            </div>
        </section>
    </main>

    <footer class="footer-simple">
        © 2026 Convertisseur. Développé par <a href="https://www.linkedin.com/in/benoit-junior10" target="_blank"> Junior Benoit </a>
    </footer>

    <script src="result.js"></script>
</body>
</html>