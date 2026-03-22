const express = require('express');
const cors = require('cors');
require('dotenv').config();

const mongoose = require('mongoose');

mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.log("MongoDB error:", err));


const app = express();

// Middleware
app.use(cors());
app.use(express.json());


const authRoutes = require('./authentication/authRoute');
const claimRoutes = require('./claims/claimRoutes');


const userProfileRoutes = require('./userprofile/userRoute');
const mlRoutes = require('./ml/mlRoutes');

app.use('/api/auth', authRoutes);
app.use('/api/user', userProfileRoutes);
app.use('/api/claims', claimRoutes);
app.use('/api/ml', mlRoutes);



// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
