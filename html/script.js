console.log('[TextChat] JavaScript loaded!');

let isOpen = false;

// DOM elements
const chatContainer = document.getElementById('chatContainer');
const messageInput = document.getElementById('messageInput');
const sendBtn = document.getElementById('sendBtn');
const cancelBtn = document.getElementById('cancelBtn');
const closeBtn = document.getElementById('closeBtn');
const charCount = document.getElementById('charCount');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    console.log('[TextChat] DOM loaded, setting up event listeners...');
    setupEventListeners();
});

function setupEventListeners() {
    console.log('[TextChat] Setting up event listeners...');
    
    // Send button
    sendBtn.addEventListener('click', sendMessage);
    
    // Cancel/Close buttons
    cancelBtn.addEventListener('click', closeChat);
    closeBtn.addEventListener('click', closeChat);
    
    // Enter key to send (Ctrl+Enter for new line)
    messageInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.ctrlKey && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    
    // Character counter
    messageInput.addEventListener('input', updateCharacterCount);
    
    // ESC key to close
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && isOpen) {
            closeChat();
        }
    });
    
    // Auto focus on input when opened
    messageInput.addEventListener('focus', () => {
        messageInput.select();
    });
    
    console.log('[TextChat] Event listeners set up successfully!');
}

function updateCharacterCount() {
    const length = messageInput.value.length;
    const maxLength = 100;
    
    charCount.textContent = length;
    
    // Update styling based on character count
    charCount.className = '';
    if (length > maxLength * 0.8) {
        charCount.classList.add('warning');
    }
    if (length > maxLength * 0.95) {
        charCount.classList.add('danger');
    }
    
    // Disable send button if empty or too long
    sendBtn.disabled = length === 0 || length > maxLength;
}

function openChat() {
    console.log('[TextChat] Opening chat UI...');
    isOpen = true;
    chatContainer.classList.add('active');
    messageInput.focus();
    updateCharacterCount();
    console.log('[TextChat] Chat UI should be visible now!');
}

function closeChat() {
    if (!isOpen) {
        console.log('[TextChat] Chat already closed, skipping...');
        return; // Already closed, prevent multiple calls
    }
    
    console.log('[TextChat] Closing chat UI...');
    isOpen = false;
    chatContainer.classList.remove('active');
    messageInput.value = '';
    updateCharacterCount();
    
    // Reset button state
    sendBtn.disabled = false;
    sendBtn.textContent = 'Изпрати';
    chatContainer.classList.remove('sending');
    
    // Notify game to close - but only once
    console.log('[TextChat] Sending close request...');
    
    fetch(`https://pure-textchat/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => {
        console.log('[TextChat] Close request completed successfully');
    }).catch(error => {
        console.log('[TextChat] Close request completed (this is normal):', error.message);
    });
}

function sendMessage() {
    const message = messageInput.value.trim();
    console.log('[TextChat] Attempting to send message:', message);
    
    if (message.length === 0) {
        showInputError('Моля въведете съобщение');
        return;
    }
    
    if (message.length > 100) {
        showInputError('Съобщението е твърде дълго');
        return;
    }
    
    // Add sending state
    chatContainer.classList.add('sending');
    sendBtn.disabled = true;
    sendBtn.textContent = 'Изпращане...';
    
    // Send to game
    console.log('[TextChat] Sending message to resource: pure-textchat');
    
    fetch(`https://pure-textchat/sendMessage`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: message
        })
    }).then(response => {
        console.log('[TextChat] Message sent successfully!');
        // Don't close - just wait for game response
    }).catch((error) => {
        console.log('[TextChat] Send request completed (this is normal):', error.message);
        // Don't close - just wait for game response
    });
}

function clearInput() {
    console.log('[TextChat] Clearing input field...');
    messageInput.value = '';
    updateCharacterCount();
    
    // Reset button state
    sendBtn.disabled = false;
    sendBtn.textContent = 'Изпрати';
    chatContainer.classList.remove('sending');
    
    // Refocus input for next message
    messageInput.focus();
}

function showInputError(message) {
    messageInput.classList.add('invalid');
    messageInput.placeholder = message;
    
    setTimeout(() => {
        messageInput.classList.remove('invalid');
        messageInput.placeholder = 'Напишете съобщение...';
    }, 3000);
}

// Message handler for game events
window.addEventListener('message', (event) => {
    console.log('[TextChat] Received message from game:', event.data);
    const data = event.data;
    
    switch (data.action) {
        case 'open':
            openChat();
            break;
            
        case 'close':
            closeChat();
            break;
            
        case 'clearInput':
            clearInput();
            break;
            
        default:
            console.log('[TextChat] Unknown action:', data.action);
            break;
    }
});

// Test function to verify everything is working
window.testTextChat = function() {
    console.log('[TextChat] Testing UI...');
    openChat();
};

console.log('[TextChat] All functions loaded!');