const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/v1/auth/otp-send', (req, res) => {
  const { phone } = req.body;
  res.json({ success: true, phone, otp_demo: '1234', message: 'OTP sent via SMS Egypt Gateway' });
});

app.get('/api/v1/services', (req, res) => {
  res.json([
    { id: 1, name_ar: 'سباكة', base_price: 150, max_price: 450 },
    { id: 2, name_ar: 'كهرباء', base_price: 150, max_price: 500 },
    { id: 3, name_ar: 'تكييف وتبريد', base_price: 250, max_price: 650 }
  ]);
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`KHADAMATY Egypt API running on port ${PORT}`));