// Global variables
let currentLanguage = localStorage.getItem('pdfQaLanguage') || 'id';
let chatHistory = [];

// Initialize when document is ready
document.addEventListener('DOMContentLoaded', function() {
    // Sidebar toggle
    const sidebarCollapse = document.getElementById('sidebarCollapse');
    const sidebarCollapseShow = document.getElementById('sidebarCollapseShow');
    const sidebar = document.getElementById('sidebar');

    if (sidebarCollapse) {
        sidebarCollapse.addEventListener('click', function() {
            sidebar.classList.remove('active');
        });
    }

    if (sidebarCollapseShow) {
        sidebarCollapseShow.addEventListener('click', function() {
            sidebar.classList.add('active');
        });
    }

    // Set active language in dropdown
    setActiveLanguage();

    // Setup language switcher
    const langOptions = document.querySelectorAll('.lang-option');
    langOptions.forEach(option => {
        option.addEventListener('click', function(e) {
            e.preventDefault();
            currentLanguage = this.getAttribute('data-lang');
            localStorage.setItem('pdfQaLanguage', currentLanguage);
            setActiveLanguage();
        });
    });

    // Initialize file dropzone if present
    initFileDropzone();

    // Initialize dataTables if present
    if (typeof $.fn.dataTable !== 'undefined') {
        $('.datatable').DataTable({
            responsive: true,
            language: {
                search: "Cari:",
                lengthMenu: "Tampilkan _MENU_ data per halaman",
                zeroRecords: "Tidak ada data yang ditemukan",
                info: "Menampilkan halaman _PAGE_ dari _PAGES_",
                infoEmpty: "Tidak ada data yang tersedia",
                infoFiltered: "(difilter dari _MAX_ total data)",
                paginate: {
                    first: "Pertama",
                    last: "Terakhir",
                    next: "Selanjutnya",
                    previous: "Sebelumnya"
                }
            }
        });
    }

    // Initialize Chatbot if on chat page
    if (document.querySelector('.chat-container')) {
        initializeChatbot();
    }

    // Initialize PDF Library
    initializePdfLibrary();

    // Initialize tooltips and popovers
    initTooltipsAndPopovers();
});

// Set active language
function setActiveLanguage() {
    const langOptions = document.querySelectorAll('.lang-option');
    langOptions.forEach(option => {
        if (option.getAttribute('data-lang') === currentLanguage) {
            option.classList.add('active');
            document.getElementById('languageDropdown').innerHTML = 
                `<i class="fas fa-globe"></i> ${currentLanguage === 'id' ? 'Indonesia' : 'English'}`;
        } else {
            option.classList.remove('active');
        }
    });
}

// Initialize file dropzone
function initFileDropzone() {
    const dropArea = document.querySelector('.file-drop-area');
    
    if (!dropArea) return;

    const fileInput = dropArea.querySelector('input[type="file"]');
    const fileInputLabel = dropArea.querySelector('.file-input-label');

    // Prevent default behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    // Highlight drop area when dragging file over it
    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, unhighlight, false);
    });

    function highlight() {
        dropArea.classList.add('active');
    }

    function unhighlight() {
        dropArea.classList.remove('active');
    }

    // Handle dropped files
    dropArea.addEventListener('drop', handleDrop, false);

    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        fileInput.files = files;
        updateFileNameDisplay(files);
    }

    // Handle file input change
    if (fileInput) {
        fileInput.addEventListener('change', function() {
            updateFileNameDisplay(this.files);
        });
    }

    function updateFileNameDisplay(files) {
        if (files.length) {
            fileInputLabel.textContent = files[0].name;
        } else {
            fileInputLabel.textContent = 'Klik atau tarik file PDF ke sini';
        }
    }
}

// Initialize chatbot
function initializeChatbot() {
    const chatForm = document.getElementById('chat-form');
    const chatInput = document.getElementById('chat-input');
    const messagesContainer = document.querySelector('.chat-messages');
    const pdfSelector = document.getElementById('pdf-selector');
    
    // Load chat history from localStorage if available
    loadChatHistory();

    // Handle PDF selection
    if (pdfSelector) {
        pdfSelector.addEventListener('change', function() {
            if (this.value) {
                // Clear chat history when changing PDFs
                chatHistory = [];
                saveChatHistory();
                messagesContainer.innerHTML = '';
                
                // Select the PDF on the server
                selectPdf(this.value);
            }
        });
    }

    // Handle chat form submission
    if (chatForm) {
        chatForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const message = chatInput.value.trim();
            
            if (message) {
                // Add user message to UI
                addMessageToUI('user', message);
                
                // Clear input
                chatInput.value = '';
                
                // Show typing indicator
                showTypingIndicator();
                
                // Send message to server
                sendMessage(message);
            }
        });
    }

    // Auto-scroll chat to bottom
    if (messagesContainer) {
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
}

// Add message to UI
function addMessageToUI(sender, content, questionId = null) {
    const messagesContainer = document.querySelector('.chat-messages');
    if (!messagesContainer) return;
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${sender}-message`;
    
    // Process the content for bot messages to ensure proper formatting
    let processedContent = content;
    if (sender === 'bot') {
        // Replace markdown-style code blocks with properly formatted HTML
        processedContent = processedContent.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
        
        // Replace markdown-style bold with HTML bold
        processedContent = processedContent.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        
        // Replace markdown-style italic with HTML italic
        processedContent = processedContent.replace(/\*(.*?)\*/g, '<em>$1</em>');
        
        // Replace asterisks used for bullet points with proper HTML
        processedContent = processedContent.replace(/^\s*\* (.*?)$/gm, '<li>$1</li>');
        processedContent = processedContent.replace(/<li>(.*?)<\/li>/g, '<ul><li>$1</li></ul>');
        processedContent = processedContent.replace(/<\/ul>\s*<ul>/g, '');
        
        // Replace markdown-style headers
        processedContent = processedContent.replace(/^# (.*?)$/gm, '<h1>$1</h1>');
        processedContent = processedContent.replace(/^## (.*?)$/gm, '<h2>$1</h2>');
        processedContent = processedContent.replace(/^### (.*?)$/gm, '<h3>$1</h3>');
        
        // Handle line breaks properly
        processedContent = processedContent.replace(/\n/g, '<br>');
    }
    
    let messageHTML = `
        <div class="message-content">${processedContent}</div>
    `;
    
    // Add feedback buttons for bot messages
    if (sender === 'bot') {
        messageHTML += `
            <div class="feedback-container">
                <button class="feedback-btn positive" data-question-id="${questionId}" onclick="giveFeedback('satisfied', '${questionId}')">
                    <i class="far fa-thumbs-up"></i>
                </button>
                <button class="feedback-btn negative" data-question-id="${questionId}" onclick="giveFeedback('unsatisfied', '${questionId}')">
                    <i class="far fa-thumbs-down"></i>
                </button>
            </div>
        `;
    }
    
    messageDiv.innerHTML = messageHTML;
    messagesContainer.appendChild(messageDiv);
    
    // Save to chat history
    chatHistory.push({
        sender: sender,
        content: content,
        timestamp: new Date().toISOString(),
        questionId: questionId
    });
    
    saveChatHistory();
    
    // Scroll to bottom
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Show typing indicator
function showTypingIndicator() {
    const messagesContainer = document.querySelector('.chat-messages');
    if (!messagesContainer) return;
    
    const typingDiv = document.createElement('div');
    typingDiv.className = 'message bot-message typing-message';
    typingDiv.innerHTML = `
        <div class="message-content">
            <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
            </div>
        </div>
    `;
    
    messagesContainer.appendChild(typingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Remove typing indicator
function removeTypingIndicator() {
    const typingMessage = document.querySelector('.typing-message');
    if (typingMessage) {
        typingMessage.remove();
    }
}

// Send message to server
function sendMessage(message) {
    const activePdf = document.getElementById('pdf-selector')?.value;
    
    if (!activePdf) {
        removeTypingIndicator();
        addMessageToUI('bot', 'Silakan pilih file PDF terlebih dahulu');
        return;
    }
    
    fetch('/ask', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            question: message,
            language: currentLanguage
        }),
    })
    .then(response => response.json())
    .then(data => {
        removeTypingIndicator();
        
        if (data.error) {
            addMessageToUI('bot', `Error: ${data.error}`);
        } else {
            // Generate a unique question ID for feedback
            const questionId = Date.now().toString();
            addMessageToUI('bot', data.response, questionId);
        }
    })
    .catch(error => {
        removeTypingIndicator();
        addMessageToUI('bot', `Terjadi kesalahan: ${error.message}`);
    });
}

// Select PDF on server
function selectPdf(pdfFilename) {
    const formData = new FormData();
    formData.append('pdf_file', pdfFilename);
    
    // Show loading state
    const messagesContainer = document.querySelector('.chat-messages');
    if (messagesContainer) {
        messagesContainer.innerHTML = '<div class="spinner"></div>';
    }
    
    fetch('/select_pdf', {
        method: 'POST',
        body: formData,
    })
    .then(response => {
        if (messagesContainer) {
            messagesContainer.innerHTML = '';
        }
        
        addMessageToUI('bot', `File ${pdfFilename} telah dipilih. Silakan ajukan pertanyaan Anda.`);
    })
    .catch(error => {
        if (messagesContainer) {
            messagesContainer.innerHTML = '';
        }
        
        addMessageToUI('bot', `Terjadi kesalahan saat memilih file: ${error.message}`);
    });
}

// Give feedback
function giveFeedback(type, questionId) {
    const questionElement = document.querySelector(`.feedback-btn[data-question-id="${questionId}"]`);
    if (!questionElement) return;
    
    // Find the question and response in chat history
    const messageIndex = chatHistory.findIndex(msg => msg.questionId === questionId);
    if (messageIndex === -1) return;
    
    // Get the question (should be the user message right before this bot message)
    const question = messageIndex > 0 ? chatHistory[messageIndex - 1].content : '';
    const response = chatHistory[messageIndex].content;
    
    // Highlight the selected feedback button
    const positiveBtn = document.querySelector(`.feedback-btn.positive[data-question-id="${questionId}"]`);
    const negativeBtn = document.querySelector(`.feedback-btn.negative[data-question-id="${questionId}"]`);
    
    if (type === 'satisfied') {
        positiveBtn.classList.add('active');
        negativeBtn.classList.remove('active');
    } else {
        negativeBtn.classList.add('active');
        positiveBtn.classList.remove('active');
    }
    
    // Send feedback to server
    fetch('/feedback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            type: type,
            message: '',
            question: question,
            response: response
        }),
    })
    .then(response => response.json())
    .then(data => {
        console.log('Feedback sent successfully:', data);
    })
    .catch(error => {
        console.error('Error sending feedback:', error);
    });
}

// Save chat history to localStorage
function saveChatHistory() {
    const activeFile = document.getElementById('pdf-selector')?.value;
    if (activeFile) {
        localStorage.setItem(`chatHistory_${activeFile}`, JSON.stringify(chatHistory));
    }
}

// Load chat history from localStorage
function loadChatHistory() {
    const activeFile = document.getElementById('pdf-selector')?.value;
    if (!activeFile) return;
    
    const savedHistory = localStorage.getItem(`chatHistory_${activeFile}`);
    if (savedHistory) {
        chatHistory = JSON.parse(savedHistory);
        
        // Add messages to UI
        const messagesContainer = document.querySelector('.chat-messages');
        if (messagesContainer) {
            messagesContainer.innerHTML = '';
            
            chatHistory.forEach(msg => {
                addMessageToUI(msg.sender, msg.content, msg.questionId);
            });
        }
    }
}

// Initialize tooltips and popovers
function initTooltipsAndPopovers() {
    // Initialize Bootstrap tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Initialize Bootstrap popovers
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
}

// Initialize PDF Library
function initializePdfLibrary() {
    const deleteButtons = document.querySelectorAll('.delete-pdf-btn');
    
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            
            if (confirm('Apakah Anda yakin ingin menghapus file ini?')) {
                const pdfId = this.getAttribute('data-pdf-id');
                deletePdf(pdfId);
            }
        });
    });
    
    // Handle preview buttons
    const previewButtons = document.querySelectorAll('.preview-pdf-btn');
    previewButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const pdfFilename = this.getAttribute('data-pdf-filename');
            const pdfUrl = `/data/${pdfFilename}`;
            
            // Open modal with PDF preview
            const modal = new bootstrap.Modal(document.getElementById('pdfPreviewModal'));
            const pdfFrame = document.getElementById('pdfPreviewFrame');
            
            if (pdfFrame) {
                pdfFrame.src = pdfUrl;
                document.getElementById('pdfPreviewTitle').textContent = pdfFilename;
            }
            
            modal.show();
        });
    });
}

// Delete PDF
function deletePdf(pdfId) {
    fetch(`/delete_pdf/${pdfId}`, {
        method: 'DELETE',
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Remove element from DOM
            const pdfElement = document.querySelector(`.pdf-file-card[data-pdf-id="${pdfId}"]`);
            if (pdfElement) {
                pdfElement.remove();
            }
            
            // Show success message
            const alertContainer = document.querySelector('.alert-container');
            if (alertContainer) {
                const alertDiv = document.createElement('div');
                alertDiv.className = 'alert alert-success alert-dismissible fade show';
                alertDiv.role = 'alert';
                alertDiv.innerHTML = `
                    ${data.message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                `;
                alertContainer.appendChild(alertDiv);
                
                // Auto-dismiss after 3 seconds
                setTimeout(() => {
                    alertDiv.remove();
                }, 3000);
            }
        } else {
            alert(`Error: ${data.error}`);
        }
    })
    .catch(error => {
        alert(`Error: ${error.message}`);
    });
}