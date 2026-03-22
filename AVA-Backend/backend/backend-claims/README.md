# AVA Claims Management Module

**Module:** Claims & Photo Upload  
**Port:** 3001

## Folder Structure

```
backend-claims/
├── package.json
├── server.js
├── .env.example          ← copy this to .env and fill in your values
├── .gitignore
└── src/
    ├── models/
    │   └── Claim.js              ← MongoDB schema
    ├── middleware/
    │   ├── auth.js               ← JWT verification
    │   └── upload.js             ← Multer file upload config
    ├── config/
    │   └── cloudinary.js         ← Cloudinary setup
    ├── services/
    │   └── damageAnalysisService.js  ← Calls AI analysis API
    ├── controllers/
    │   ├── claimController.js    ← Claim logic
    │   └── photoController.js    ← Photo upload logic
    └── routes/
        ├── claims.js             ← Claim routes
        └── photos.js             ← Photo routes
```

## Setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Open .env and fill in your values
```

### 3. Start the server
```bash
npm run dev
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/claims/submit | Submit a new claim |
| GET | /api/claims | Get all claims for logged-in user |
| GET | /api/claims/:id | Get a single claim |
| PUT | /api/claims/:id/status | Update claim status |
| POST | /api/claims/:id/dispute | Submit a dispute |
| GET | /api/claims/:id/report | Download PDF report |
| POST | /api/claims/:claimId/photos | Upload photos |
| GET | /api/claims/:claimId/photos | Get photos for a claim |

All endpoints require `Authorization: Bearer <JWT_TOKEN>` header.

## Generating a Test Token

```bash
node -e "
const jwt = require('jsonwebtoken');
const token = jwt.sign({ id: '507f1f77bcf86cd799439011' }, 'your-jwt-secret');
console.log(token);
"
```

## Integration

- **Auth Module** — shares JWT_SECRET
- **AI Analysis Service** — runs on port 5002
- **Cloudinary** — stores uploaded photos
