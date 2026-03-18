const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// FIX: Check if the service account file exists before trying to load it.
// The original code would crash the entire server on startup if the file
// was missing. Now it logs a warning and continues — the server still starts
// and all non-Firebase routes work fine.

const serviceAccountPath = path.join(__dirname, 'firebase-service-account.json');

if (fs.existsSync(serviceAccountPath)) {
  try {
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });

    console.log('✅ Firebase Admin initialized');
  } catch (error) {
    console.error('❌ Firebase initialization error:', error.message);
    console.error('⚠️  Check that firebase-service-account.json is valid JSON');
    console.error('📖 See src/config/FIREBASE-SETUP.md for instructions');
  }
} else {
  console.warn('⚠️  firebase-service-account.json not found in src/config/');
  console.warn('⚠️  Push notifications will be disabled until this is set up');
  console.warn('📖 See src/config/FIREBASE-SETUP.md for setup instructions');
}

module.exports = admin;
