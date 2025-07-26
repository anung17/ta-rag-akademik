document.addEventListener('DOMContentLoaded', function() {
    // Toggle password visibility
    const togglePasswordButtons = document.querySelectorAll('.toggle-password');
    togglePasswordButtons.forEach(button => {
        button.addEventListener('click', function() {
            const passwordInput = this.previousElementSibling;
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                this.classList.remove('fa-eye');
                this.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                this.classList.remove('fa-eye-slash');
                this.classList.add('fa-eye');
            }
        });
    });

    // Show/hide admin code field based on checkbox
    const adminCheckbox = document.getElementById('is_admin');
    const adminCodeGroup = document.querySelector('.admin-code-group');
    
    if (adminCheckbox && adminCodeGroup) {
        adminCheckbox.addEventListener('change', function() {
            if (this.checked) {
                adminCodeGroup.style.display = 'block';
            } else {
                adminCodeGroup.style.display = 'none';
                document.getElementById('admin_code').value = '';
            }
        });
    }

    // Register form validation 
    const registerForm = document.getElementById('register-form');
    if (registerForm) {
        registerForm.addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm-password').value;
            const username = document.getElementById('username').value;
            const email = document.getElementById('email').value;
            const isAdmin = document.getElementById('is_admin').checked;
            const adminCode = document.getElementById('admin_code').value;

            // Clear previous error messages
            clearMessages();

            // Basic validation
            if (!username || !email || !password || !confirmPassword) {
                e.preventDefault();
                showMessage('Semua field harus diisi', 'error');
                return;
            }

            // Password matching
            if (password !== confirmPassword) {
                e.preventDefault();
                showMessage('Password dan konfirmasi password tidak cocok', 'error');
                return;
            }

            // Password strength
            if (password.length < 6) {
                e.preventDefault();
                showMessage('Password harus minimal 6 karakter', 'error');
                return;
            }

            // Admin code validation
            if (isAdmin && !adminCode) {
                e.preventDefault();
                showMessage('Kode admin harus diisi jika mendaftar sebagai admin', 'error');
                return;
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                showMessage('Format email tidak valid', 'error');
                return;
            }
        });
    }

    // Login form validation
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;

            // Clear previous error messages
            clearMessages();

            // Basic validation
            if (!username || !password) {
                e.preventDefault();
                showMessage('Username dan password harus diisi', 'error');
                return;
            }
        });
    }

    // Handle flash messages from URL parameters
    function handleFlashMessages() {
        const urlParams = new URLSearchParams(window.location.search);
        const flashType = urlParams.get('flash_type');
        const flashMessage = urlParams.get('flash_message');
        
        if (flashType && flashMessage) {
            showMessage(decodeURIComponent(flashMessage), flashType);
            
            // Clean up the URL without refreshing
            const url = new URL(window.location);
            url.searchParams.delete('flash_type');
            url.searchParams.delete('flash_message');
            window.history.replaceState({}, '', url);
        }
    }

    // Function to show messages
    function showMessage(message, type) {
        const messageContainer = document.getElementById('message-container');
        if (!messageContainer) return;

        const messageDiv = document.createElement('div');
        messageDiv.className = `flash-message flash-${type}`;
        
        // Add appropriate icon
        let icon = '';
        if (type === 'success') {
            icon = 'fa-check-circle';
        } else if (type === 'error') {
            icon = 'fa-exclamation-circle';
        } else if (type === 'warning') {
            icon = 'fa-exclamation-triangle';
        }
        
        messageDiv.innerHTML = `<i class="fas ${icon}"></i>${message}`;
        messageContainer.appendChild(messageDiv);
        
        // Auto-dismiss after 5 seconds
        setTimeout(() => {
            messageDiv.remove();
        }, 5000);
    }

    // Function to clear all messages
    function clearMessages() {
        const messageContainer = document.getElementById('message-container');
        if (messageContainer) {
            messageContainer.innerHTML = '';
        }
    }

    // Check for flash messages on page load
    handleFlashMessages();
});