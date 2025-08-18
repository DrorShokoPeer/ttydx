const express = require('express');
const session = require('express-session');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const winston = require('winston');
const path = require('path');

const app = express();

// Logging setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/app/logs/auth.log' }),
    new winston.transports.Console()
  ]
});

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:"],
      connectSrc: ["'self'", "ws:", "wss:"]
    }
  }
}));

// Rate limiting
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Session management
app.use(session({
  secret: process.env.SESSION_SECRET || 'your-secret-key-change-in-production',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Default users (in production, use database)
const users = {
  'admin': {
    password: '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj2sBtlzk7.e', // 'admin123'
    role: 'admin'
  },
  'user': {
    password: '$2a$12$92z/gHquqNEY0B8EWOOPee/CJaUl/V7zQm0s8YJRHVa3cH3xqiQ5W', // 'user123'
    role: 'user'
  }
};

// Authentication middleware
const requireAuth = (req, res, next) => {
  if (req.session.user) {
    next();
  } else {
    res.status(401).json({ error: 'Authentication required' });
  }
};

// Routes
app.get('/', (req, res) => {
  if (req.session.user) {
    res.redirect('/terminal');
  } else {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
  }
});

app.post('/auth/login', loginLimiter, async (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password required' });
  }

  const user = users[username];
  if (!user || !await bcrypt.compare(password, user.password)) {
    logger.warn(`Failed login attempt for user: ${username}`, { ip: req.ip });
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  req.session.user = { username, role: user.role };
  logger.info(`Successful login for user: ${username}`, { ip: req.ip });
  
  res.json({ success: true, redirect: '/terminal' });
});

app.post('/auth/logout', (req, res) => {
  const username = req.session.user?.username;
  req.session.destroy((err) => {
    if (err) {
      logger.error('Session destruction error', err);
      return res.status(500).json({ error: 'Logout failed' });
    }
    logger.info(`User logged out: ${username}`, { ip: req.ip });
    res.json({ success: true, redirect: '/' });
  });
});

app.get('/terminal', requireAuth, (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'terminal.html'));
});

app.get('/auth/status', (req, res) => {
  if (req.session.user) {
    res.json({ authenticated: true, user: req.session.user });
  } else {
    res.json({ authenticated: false });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const PORT = process.env.AUTH_PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Authentication server running on port ${PORT}`);
});