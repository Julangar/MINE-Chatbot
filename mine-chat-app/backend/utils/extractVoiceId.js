function extractVoiceIdFromUrl(url) {
  const match = url.match(/\/voices\/([a-zA-Z0-9-]+)\//);
  return match ? match[1] : null;
}

module.exports = extractVoiceIdFromUrl;
