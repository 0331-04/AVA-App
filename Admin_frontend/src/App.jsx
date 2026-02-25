import { Routes, Route } from "react-router-dom";
import { Toaster } from "react-hot-toast";

import Splash from "./pages/Splash";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Claims from "./pages/Claims";
import ClaimDetails from "./pages/ClaimDetails";

function App() {
  return (
    <>
      {/* Toast notifications */}
      <Toaster position="top-right" />

      {/* App Routes */}
      <Routes>
        <Route path="/" element={<Splash />} />
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/claims" element={<Claims />} />
        <Route path="/claims/:id" element={<ClaimDetails />} />
      </Routes>
    </>
  );
}

export default App;