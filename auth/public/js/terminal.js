class TerminalManager {
    constructor() {
        this.sessions = new Map();
        this.currentSession = null;
        this.init();
    }

    async init() {
        await this.checkAuth();
        this.setupEventListeners();
        this.loadSettings();
        this.createDefaultSession();
    }

    async checkAuth() {
        try {
            const response = await fetch('/auth/status');
            const data = await response.json();
            
            if (!data.authenticated) {
                window.location.href = '/';
                return;
            }
            
            document.getElementById('userInfo').textContent = `Welcome, ${data.user.username}`;
        } catch (error) {
            console.error('Auth check failed:', error);
            window.location.href = '/';
        }
    }

    setupEventListeners() {
        // Logout
        document.getElementById('logoutBtn').addEventListener('click', async () => {
            try {
                await fetch('/auth/logout', { method: 'POST' });
                window.location.href = '/';
            } catch (error) {
                console.error('Logout failed:', error);
            }
        });

        // Theme toggle
        document.getElementById('themeToggle').addEventListener('click', () => {
            this.toggleTheme();
        });

        // Settings modal
        document.getElementById('settingsBtn').addEventListener('click', () => {
            document.getElementById('settingsModal').style.display = 'flex';
        });

        document.getElementById('closeSettings').addEventListener('click', () => {
            document.getElementById('settingsModal').style.display = 'none';
        });

        document.getElementById('saveSettings').addEventListener('click', () => {
            this.saveSettings();
            document.getElementById('settingsModal').style.display = 'none';
        });

        document.getElementById('cancelSettings').addEventListener('click', () => {
            document.getElementById('settingsModal').style.display = 'none';
        });

        // New session
        document.getElementById('newSessionBtn').addEventListener('click', () => {
            this.createNewSession();
        });
    }

    createDefaultSession() {
        this.createSession('Main', true);
    }

    createNewSession() {
        const sessionName = `Session ${this.sessions.size + 1}`;
        this.createSession(sessionName);
    }

    createSession(name, isDefault = false) {
        const sessionId = Date.now().toString();
        const session = {
            id: sessionId,
            name: name,
            url: `/ttyd?session=${sessionId}`,
            active: false
        };

        this.sessions.set(sessionId, session);
        this.renderSessionList();
        
        if (isDefault || this.sessions.size === 1) {
            this.switchToSession(sessionId);
        }
    }

    switchToSession(sessionId) {
        // Deactivate current session
        if (this.currentSession) {
            this.sessions.get(this.currentSession).active = false;
        }

        // Activate new session
        this.currentSession = sessionId;
        this.sessions.get(sessionId).active = true;

        // Update UI
        this.renderSessionList();
        this.updateTerminalFrame(sessionId);
    }

    updateTerminalFrame(sessionId) {
        const session = this.sessions.get(sessionId);
        const frame = document.getElementById('terminalFrame');
        frame.src = session.url;
    }

    renderSessionList() {
        const sessionList = document.getElementById('sessionList');
        sessionList.innerHTML = '';

        this.sessions.forEach((session, id) => {
            const sessionItem = document.createElement('div');
            sessionItem.className = `session-item ${session.active ? 'active' : ''}`;
            sessionItem.innerHTML = `
                <span class="session-name">${session.name}</span>
                <button class="close-session" data-session-id="${id}">&times;</button>
            `;
            
            sessionItem.addEventListener('click', (e) => {
                if (!e.target.classList.contains('close-session')) {
                    this.switchToSession(id);
                }
            });

            sessionItem.querySelector('.close-session').addEventListener('click', (e) => {
                e.stopPropagation();
                this.closeSession(id);
            });

            sessionList.appendChild(sessionItem);
        });
    }

    closeSession(sessionId) {
        if (this.sessions.size <= 1) {
            alert('Cannot close the last session');
            return;
        }

        this.sessions.delete(sessionId);
        
        if (this.currentSession === sessionId) {
            // Switch to first available session
            const firstSession = this.sessions.keys().next().value;
            this.switchToSession(firstSession);
        }
        
        this.renderSessionList();
    }

    toggleTheme() {
        const body = document.body;
        const currentTheme = body.getAttribute('data-theme') || 'dark';
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        body.setAttribute('data-theme', newTheme);
        localStorage.setItem('terminal-theme', newTheme);
        
        const themeToggle = document.getElementById('themeToggle');
        themeToggle.textContent = newTheme === 'dark' ? '🌙' : '☀️';
    }

    loadSettings() {
        // Load theme
        const savedTheme = localStorage.getItem('terminal-theme') || 'dark';
        document.body.setAttribute('data-theme', savedTheme);
        document.getElementById('themeToggle').textContent = savedTheme === 'dark' ? '🌙' : '☀️';

        // Load other settings
        const fontSize = localStorage.getItem('terminal-font-size') || '14';
        const fontFamily = localStorage.getItem('terminal-font-family') || 'monospace';
        
        this.applyTerminalSettings({ fontSize, fontFamily });
    }

    saveSettings() {
        const theme = document.getElementById('themeSelect').value;
        const fontSize = document.getElementById('fontSizeSelect').value;
        const fontFamily = document.getElementById('fontFamilySelect').value;

        localStorage.setItem('terminal-theme', theme);
        localStorage.setItem('terminal-font-size', fontSize);
        localStorage.setItem('terminal-font-family', fontFamily);

        document.body.setAttribute('data-theme', theme);
        this.applyTerminalSettings({ fontSize, fontFamily });
    }

    applyTerminalSettings(settings) {
        const terminalFrame = document.getElementById('terminalFrame');
        // Settings will be applied to ttyd via URL parameters
        if (this.currentSession) {
            const session = this.sessions.get(this.currentSession);
            const url = new URL(session.url, window.location.origin);
            url.searchParams.set('fontSize', settings.fontSize);
            url.searchParams.set('fontFamily', settings.fontFamily);
            terminalFrame.src = url.toString();
        }
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new TerminalManager();
});
