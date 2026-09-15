const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth.routes');
const alertsRoutes = require('./routes/alerts.routes');
const strikesRoutes = require('./routes/strikes.routes');
const { errorHandler, notFound } = require('./middleware/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

app.use('/api/auth', authRoutes);
app.use('/api/alerts', alertsRoutes);
app.use('/api/strikes', strikesRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
