function healthCheck(req, res) {
  console.log('✔️ Health check ejecutado');
  res.json({ status: 'ok', message: 'Servidor funcionando correctamente' });
}
