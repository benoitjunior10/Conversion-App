<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Convertisseur - Accueil</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <link rel="stylesheet" href="style.css">
</head>
<body class="page-home">

    <header class="navbar sticky-header bg-white-nav">
        <div class="logo">
            <span class="material-symbols-outlined logo-icon">sync_alt</span>
            <span class="logo-text">Convertisseur</span>
        </div>
        <nav class="nav-links">
            <a href="#">Accueil</a>
            <a href="#">Outils</a>
            <a href="#">Tarifs</a>
            <a href="#">Aide</a>
        </nav>
        <div class="nav-auth">
            <button class="btn btn-primary">Connexion</button>
        </div>
    </header>

    <main class="hero-section">
        <div class="hero-text">
            <h1>Convertissez vos documents instantanément</h1>
            <p>Transformez vos fichiers Word, PDF et Excel en quelques secondes. Sécurisé, rapide et gratuit jusqu'à 50 Mo.</p>
        </div>

        <form id="conversionForm" action="convert" method="POST" enctype="multipart/form-data" style="display:none;">
            <input type="file" name="file" id="realFileInput">
            <input type="text" name="mode" id="realModeInput" value="WORD_TO_PDF">
        </form>

        <div class="converter-card">
            <div class="drop-zone" id="dropZone">
                <div class="drop-content" id="dropContent">
                    <div class="cloud-icon-circle">
                        <span class="material-symbols-outlined">cloud_upload</span>
                    </div>
                    <h2 id="dropText">Glissez-d�posez votre fichier ici</h2>
                    <p class="meta" id="fileInfo">Max 50 Mo ? PDF, DOCX, XLSX</p>
                    <button class="btn btn-white" id="browseBtn">Choisir un fichier</button>
                </div>
            </div>

            <form id="conversionForm" action="convert" method="POST" enctype="multipart/form-data" style="display:none;">
                <input type="file" name="file" id="realFileInput" accept=".docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document">
                <input type="hidden" name="mode" id="realModeInput" value="WORD_TO_PDF">
            </form>

            <div class="converter-card">
                <div class="conversion-controls">
                    <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
                        <% if (errorMessage != null) { %>
                                <div class="alert-error">
                                    <span class="material-symbols-outlined">error</span>
                                    <span><%= errorMessage %></span>
                                </div>
                            <% } %>
                    <label class="control-label">Mode de conversion</label>
                    <div class="control-row">
            
                        <div class="select-box">
                            <span class="material-symbols-outlined select-icon-left" id="dynamicModeIcon">description</span>
                      
                            <select id="modeSelectNative">
                                <option value="WORD_TO_PDF">Word vers PDF</option>
                                <option value="PDF_TO_WORD">PDF vers Word</option>
                                <option value="PDF_TO_EXCEL">PDF vers Excel</option>
                            </select>

                            <span class="material-symbols-outlined select-chevron-right">expand_more</span>
                        </div>
            
                        <button class="btn btn-blue-action" id="convertBtn">
                            Convertir <span class="material-symbols-outlined">arrow_forward</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="trust-bar">
            <div class="trust-item">
                <div class="check-circle">
                    <span class="material-symbols-outlined">verified_user</span>
                </div>
                <div class="trust-text">
                    <strong>Sécurité garantie</strong>
                </div>
            </div>
            <div class="server-item">
                <div class="server-header">
                    <span>Serveurs de conversion</span>
                    <span class="status-ok"><span class="dot"></span> Opérationnels</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill"></div>
                </div>
            </div>
        </div>
    </main>

    <footer class="footer">
        <div class="footer-links">
            <a href="#">Politique de confidentialité</a>
            <span class="separator">?</span>
            <a href="#">Conditions d'utilisation</a>
            <span class="separator">?</span>
            <a href="#">Contact</a>
        </div>
    </footer>

    <script src="home.js"></script>
</body>
</html>