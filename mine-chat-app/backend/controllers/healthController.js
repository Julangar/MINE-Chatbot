function healthCheck(req, res) {
  res.json({ status: 'ok', message: 'Servidor funcionando correctamente' });
}

module.exports = { healthCheck };
