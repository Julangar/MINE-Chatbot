const express = require('express');
const cors = require('cors');
const errorHandler = require('./middlewares/errorHandler');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api', require('./routes/health'));
app.use('/api/user', require('./routes/user'));
app.use('/api/chat', require('./routes/chat'));
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
