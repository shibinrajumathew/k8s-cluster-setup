// node-backend/index.js
const express = require('express');
const app = express();
const port = 5000;

// Access token for validation
const ACCESS_TOKEN = process.env.ACCESSTOKEN;
console.log(`Access token: ${ACCESS_TOKEN}`); // Log the access token

app.use(express.json());

app.use((req, res, next) => {
  const token = req.headers['accesstoken'];
  if (token === ACCESS_TOKEN) {
    next();
  } else {
    res.status(403).json({ message: 'Forbidden' });
  }
});

app.get('/api', (req, res) => {
  res.send('Welcome to the API');
});

app.post('/api/create', (req, res) => {
  res.json({ operation: 'create' });
});

app.get('/api/read', (req, res) => {
  res.json({ operation: 'read' });
});

app.put('/api/update', (req, res) => {
  res.json({ operation: 'update' });
});

app.delete('/api/delete', (req, res) => {
  res.json({ operation: 'delete' });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
