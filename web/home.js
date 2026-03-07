/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('dropZone');
    const realFileInput = document.getElementById('realFileInput');
    const browseBtn = document.getElementById('browseBtn');
    const dropText = document.getElementById('dropText');
    const fileInfo = document.getElementById('fileInfo');
    const convertBtn = document.getElementById('convertBtn');
    const conversionForm = document.getElementById('conversionForm');

    const modeSelectNative = document.getElementById('modeSelectNative');
    const realModeInput = document.getElementById('realModeInput'); // L'input caché dans le form
    const dynamicModeIcon = document.getElementById('dynamicModeIcon');

    // Map des icônes selon la valeur
    const iconsMap = {
        'WORD_TO_PDF': 'description',
        'PDF_TO_WORD': 'picture_as_pdf',
        'PDF_TO_EXCEL': 'picture_as_pdf'
    };
    
    const acceptMap = {
        'WORD_TO_PDF': '.docx,application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'PDF_TO_WORD': '.pdf,application/pdf',
        'PDF_TO_EXCEL': '.pdf,application/pdf'
    };

    
    // Fonction de mise à jour
    function updateMode() {
        const val = modeSelectNative.value;
        
        // Mettre à jour l'input caché (celui qui part au serveur)
        realModeInput.value = val;
        
        // Mettre à jour l'icône visuelle
        if(iconsMap[val]) {
            dynamicModeIcon.textContent = iconsMap[val];
        }
        // Mettre à jour le filtre (accept) selon le mode choisi
        if (acceptMap[val]) {
            realFileInput.setAttribute('accept', acceptMap[val]);
        } else {
            realFileInput.removeAttribute('accept');
        }
    }

    // Écouteur sur le changement natif
    if(modeSelectNative) {
        modeSelectNative.addEventListener('change', updateMode);
        // Initialisation au chargement (au cas où le navigateur garde une valeur en cache)
        updateMode();
    }

    
    browseBtn.addEventListener('click', () => realFileInput.click());

    realFileInput.addEventListener('change', handleFileSelect);

    dropZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropZone.style.borderColor = 'var(--primary-blue)';
        dropZone.style.background = '#ebf5ff';
    });

    dropZone.addEventListener('dragleave', (e) => {
        e.preventDefault();
        dropZone.style.borderColor = 'transparent';
        dropZone.style.background = 'linear-gradient(135deg, #e3edf7 0%, #cbddec 100%)';
    });

    dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.style.borderColor = 'transparent';
        dropZone.style.background = 'linear-gradient(135deg, #e3edf7 0%, #cbddec 100%)';
        
        if (e.dataTransfer.files.length > 0) {
            realFileInput.files = e.dataTransfer.files;
            handleFileSelect();
        }
    });

    function handleFileSelect() {
        if (realFileInput.files.length > 0) {
            const file = realFileInput.files[0];
            dropText.textContent = file.name;
            fileInfo.textContent = formatBytes(file.size);
            document.querySelector('.cloud-icon-circle span').textContent = 'check';
            document.querySelector('.cloud-icon-circle').style.color = '#22C55E';
        }
    }

    function formatBytes(bytes, decimals = 2) {
        if (!+bytes) return '0 Bytes';
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`;
    }

    // --- Soumission ---
    convertBtn.addEventListener('click', () => {
        if (realFileInput.files.length === 0) {
            alert("Veuillez sélectionner un fichier d'abord.");
            return;
        }
        
        convertBtn.disabled = true;
        browseBtn.disabled = true;
        modeSelectNative.disabled = true;
    
        // Petit effet de chargement
        convertBtn.innerHTML = 'Conversion... <span class="material-symbols-outlined">sync</span>';
        convertBtn.style.opacity = '0.8';
        
        // On s'assure une dernière fois que le mode est bien synchronisé avant l'envoi
        realModeInput.value = modeSelectNative.value; 
        
        conversionForm.submit();
    });
});
