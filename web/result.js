/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

document.addEventListener('DOMContentLoaded', () => {
    
    // --- Copie du lien de partage ---
    const copyLinkBtn = document.getElementById('copyLinkBtn');
    
    if(copyLinkBtn) {
        copyLinkBtn.addEventListener('click', () => {
            // Utilise la config injectée dans le JSP
            const link = CONFIG.shareLink;
            
            if (navigator.clipboard) {
                navigator.clipboard.writeText(link).then(() => {
                    alert('Lien copié dans le presse-papier !');
                }).catch(err => {
                    console.error('Erreur copie', err);
                    prompt("Copiez ce lien :", link);
                });
            } else {
                prompt("Copiez ce lien :", link);
            }
        });
    }

    // Gestion de la hauteur de l'iframe (responsive)
    const viewer = document.getElementById('docViewerContainer');
    if(viewer) {
        // on pourrait ajouter des boutons de zoom custom si on ne voulait pas utiliser ceux du navigateur PDF natif
    }
});
