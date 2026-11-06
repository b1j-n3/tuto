const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// In production, load from process.env.QR_SECRET_KEY
const JWT_SECRET_KEY = 'tuto-dod-cyber-secret-key-change-in-production';

// 1. GENERATE ROTATING DYNAMIC QR TOKEN (Nanny Device Endpoint)
app.post('/api/v1/qr/generate', (req, res) => {
  const { shiftId, nannyId } = req.body;

  if (!shiftId || !nannyId) {
    return res.status(400).json({ success: false, message: 'Missing shift or nanny identity.' });
  }

  // Token expires in 60 seconds to prevent replay/screenshot fraud
  const token = jwt.sign(
    { shiftId, nannyId, issuedAt: Date.now() },
    JWT_SECRET_KEY,
    { expiresIn: '60s' }
  );

  res.json({ success: true, qrToken: token, expiresInSeconds: 60 });
});

// 2. VERIFY QR TOKEN ON CHECK-IN (Parent App or Nanny Scanner)
app.post('/api/v1/qr/verify', (req, res) => {
  const { qrToken, parentUserId } = req.body;

  if (!qrToken) {
    return res.status(400).json({ success: false, message: 'Missing QR verification code.' });
  }

  try {
    const decoded = jwt.verify(qrToken, JWT_SECRET_KEY);
    
    // In production: Query DB to check shift matching and mark status = ACTIVE
    return res.json({
      success: true,
      message: 'Check-in authenticated. Session active.',
      shiftId: decoded.shiftId,
      nannyId: decoded.nannyId,
      verifiedAt: new Date().toISOString()
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'QR Code expired. Refresh screen.' });
    }
    return res.status(401).json({ success: false, message: 'Cryptographic validation failed.' });
  }
});

// 3. 1-CLICK URGENT DISPATCH MATCHING ENGINE
app.post('/api/v1/dispatch/urgent', (req, res) => {
  const { parentId, childrenCount, address } = req.body;

  // Mock instant algorithmic match response
  const assignedSitter = {
    shiftId: 'shift_' + Math.random().toString(36).substr(2, 9),
    nannyName: 'Sarah M., RN',
    clearance: 'DoD Intelligence Vetted',
    rnBadge: 'Texas Board of Nursing #89421',
    cprCert: 'Active (AHA Pediatric ER)',
    etaMinutes: 14
  };

  res.json({ success: true, dispatch: assignedSitter });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Tuto Backend API running on port ${PORT}`));