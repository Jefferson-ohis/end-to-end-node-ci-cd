const express = require('express');
const client = require('prom-client');
const app = express();

// Collect default system metrics
client.collectDefaultMetrics();

// Custom counter
const counter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
});

// Home route (UI)
app.get('/', (req, res) => {
  counter.inc();

  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>DevOps Monitoring App</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: #0f172a;
          color: #e5e7eb;
          display: flex;
          align-items: center;
          justify-content: center;
          height: 100vh;
          margin: 0;
        }
        .card {
          background: #020617;
          padding: 30px;
          border-radius: 10px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.6);
          max-width: 500px;
          text-align: center;
        }
        h1 {
          color: #38bdf8;
        }
        .badge {
          display: inline-block;
          margin-top: 10px;
          padding: 6px 12px;
          border-radius: 999px;
          background: #22c55e;
          color: #022c22;
          font-weight: bold;
          font-size: 14px;
        }
        .links {
          margin-top: 20px;
        }
        a {
          color: #38bdf8;
          text-decoration: none;
          margin: 0 10px;
        }
        a:hover {
          text-decoration: underline;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>🚀 DevOps Monitoring App</h1>
        <p>This Node.js app exposes Prometheus metrics.</p>
        <span class="badge">STATUS: RUNNING</span>

        <div class="links">
          <a href="/health">Health</a>
          <a href="/metrics">Metrics</a>
        </div>
      </div>
    </body>
    </html>
  `);
});

// Health check
app.get('/health', (req, res) => res.send('ok'));

// Prometheus metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(3000, () => console.log('Listening on port 3000'));