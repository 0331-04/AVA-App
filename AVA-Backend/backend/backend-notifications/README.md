# AVA Notifications Module

**Module:** Notifications & Push Messaging  
**Port:** 3002

## Folder Structure

```
backend-notifications/
├── package.json
├── server.js
├── .env.example          ← copy this to .env and fill in your values
├── .gitignore
└── src/
    ├── models/
    │   ├── Notification.js       ← stores all notifications in MongoDB
    │   └── UserToken.js          ← stores FCM device tokens per user
    ├── middleware/
    │   └── auth.js               ← JWT verification (same as claims module)
    ├── config/
    │   ├── firebase.js           ← Firebase Admin SDK setup
    │   └── FIREBASE-SETUP.md     ← step-by-step Firebase setup guide
    ├── services/
    │   └── notificationService.js  ← create notifications + send push via FCM
    ├── controllers/
    │   └── notificationController.js
    └── routes/
        └── notifications.js
```

## Setup

### 1. Install dependencies
```bash
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Set JWT_SECRET to the same value used in your auth and claims modules
```

### 3. Set up Firebase (for push notifications)
Follow the instructions in `src/config/FIREBASE-SETUP.md`

### 4. Start the server
```bash
npm run dev
```

## API Endpoints

All endpoints require `Authorization: Bearer <JWT_TOKEN>` header.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/notifications | Get all notifications + unread count |
| POST | /api/notifications/read | Mark specific notifications as read |
| POST | /api/notifications/read-all | Mark all as read |
| DELETE | /api/notifications | Clear all notifications |
| DELETE | /api/notifications/:id | Delete a single notification |
| POST | /api/notifications/fcm-token | Save device FCM token |
| POST | /api/notifications/create | Create notification (used by claims module) |

## Integration with Claims Module

When a claim status changes, the claims module should call:

```javascript
await axios.post('http://localhost:3002/api/notifications/create',
  {
    userId: claim.userId,
    type: 'approved',
    title: 'Claim Approved',
    message: `Your claim ${claim.claimNumber} has been approved`,
    claimId: claim._id
  },
  {
    headers: { Authorization: `Bearer ${serviceToken}` }
  }
);
```

Note: A valid JWT token must be included — the `/create` endpoint requires auth.

## Notification Types

`claim_submitted` · `ai_analysis_complete` · `in_review` · `assessment_done` ·
`approved` · `rejected` · `payment_processing` · `dispute_submitted` · `general`

## Important Notes

- Firebase push notifications require `firebase-service-account.json` in `src/config/`
- **Never commit that file to Git** — it's already blocked in `.gitignore`
- The server starts and all routes work even without Firebase set up
- Push notifications are simply skipped if Firebase isn't configured
