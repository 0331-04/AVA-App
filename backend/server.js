const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());


const userRoutes = require('./routes/users');
const claimRoutes = require('./routes/claims');


const qualityRoutes = require('./routes/quality_routes');
const damageRoutes = require('./routes/damage_routes');

app.use('/api/users', userRoutes);
app.use('/api/claims', claimRoutes);


app.use('/api/quality', qualityRoutes);
app.use('/api/damage', damageRoutes);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});