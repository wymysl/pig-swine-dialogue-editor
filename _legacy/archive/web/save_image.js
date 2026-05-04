import fs from 'fs';
import http from 'http';

const server = http.createServer((req, res) => {
  if (req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', () => {
      const base64Data = body.replace(/^data:image\/png;base64,/, "");
      fs.mkdirSync('./artifacts/Sprint0', { recursive: true });
      fs.writeFileSync('./artifacts/Sprint0/portraits.png', base64Data, 'base64');
      res.end('OK');
      console.log('Saved image successfully');
      process.exit(0);
    });
  } else {
    res.end(fs.readFileSync('./render_portraits_inline.html'));
  }
});

server.listen(0, '127.0.0.1', () => {
  console.log('PORT:' + server.address().port);
});
