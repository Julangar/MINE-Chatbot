const express = require('express');
const app = express();
app.use(express.json());

const avatarRoutes = require('./routes/avatar');
app.use('/api/avatars', avatarRoutes);

// ...otros middlewares y rutas

module.exports = app;