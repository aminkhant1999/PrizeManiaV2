const path = require('path');
const express = require('express');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
dotenv.config({ quiet: true });

const db = require('./config/db');
const { createSessionMiddleware } = require('./config/session');
const flashMiddleware = require('./middleware/flashMiddleware');
const csrfProtection = require('./middleware/csrfMiddleware');
const homeRoutes = require('./routes/homeRoutes');
const pageRoutes = require('./routes/pageRoutes');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const adminRoutes = require('./routes/adminRoutes');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');

function createApp(options = {}) {
  const app = express();
  if (process.env.NODE_ENV === 'production') app.set('trust proxy', 1);
  app.set('view engine', 'ejs');
  app.set('views', path.join(__dirname, 'views'));
  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(express.urlencoded({ extended: false, limit: '20kb' }));
  app.use(express.json({ limit: '20kb' }));
  app.use(express.static(path.join(__dirname, 'public')));
  app.use(createSessionMiddleware({ useMemoryStore: options.useMemoryStore }));
  app.use(flashMiddleware);
  app.use((req, res, next) => {
    res.locals.currentUser = req.session.user || null;
    res.locals.currentPath = req.path;
    res.locals.old = {};
    res.locals.errors = [];
    next();
  });
  app.use(csrfProtection);
  app.use('/', homeRoutes, pageRoutes);
  app.use('/', rateLimit({ windowMs: 15 * 60 * 1000, limit: 30, standardHeaders: 'draft-8', legacyHeaders: false }), authRoutes);
  app.use('/', userRoutes);
  app.use('/admin', adminRoutes);
  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}

async function startServer() {
  try {
    await db.initializePool();
    const port = Number(process.env.PORT) || 3000;
    createApp().listen(port, () => console.log(`PrizeMania is running at http://localhost:${port}`));
  } catch (error) {
    console.error('Unable to start PrizeMania due to database connection issues:', error.message);
    process.exitCode = 1;
  }
}

if (require.main === module) startServer();
module.exports = { createApp, startServer };
