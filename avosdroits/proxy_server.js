const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

app.post('/api/chat', async (req, res) => {
  try {
    const response = await axios.post(
      'https://api.together.xyz/v1/chat/completions',
      req.body,
      {
        headers: {
          'Authorization': 'Bearer 2ee77740fb8e9be697f1825667f26265ce563fae5db231f95aa2356ed5a72f8f',
          'Content-Type': 'application/json',
        },
      }
    );
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({
      error: error.response?.data || 'Internal Server Error',
    });
  }
});

app.listen(port, () => {
  console.log(`Proxy server running at http://localhost:${port}`);
}); 