import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import logo from "../assets/ava-logo-full.png";

function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/login");
    }, 5000);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div style={styles.container}>
      {/* White Circle with Logo */}
      <div style={styles.circle}>
        <img src={logo} alt="AVA Logo" style={styles.logo} />
      </div>

      {/* Loading bar */}
      <div style={styles.loaderBg}>
        <div style={styles.loader}></div>
      </div>

      <p style={styles.loadingText}>Loading...</p>
    </div>
  );
}

const styles = {
  container: {
    height: "100vh",
    width: "100vw",
    background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
  },
  circle: {
    width: "260px",
    height: "220px",
    borderRadius: "50%",
    background: "#ffffff",
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: "50px",
  },
  logo: {
    width: "250px",
    height: "250px",
    
  },
  loaderBg: {
    width: "220px",
    height: "6px",
    background: "rgba(255,255,255,0.4)",
    borderRadius: "10px",
    overflow: "hidden",
  },
  loader: {
  height: "100%",
  width: "100%",
  background: "linear-gradient(90deg, #00e0ff, #66f0ff, #00e0ff)",
  backgroundSize: "200px 100%",
  animation: "load 5s ease-in-out forwards, shimmer 1.5s infinite",
  },

  loadingText: {
    marginTop: "14px",
    color: "#ffffff",
    fontSize: "14px",
    opacity: 0.9,
  },
  
};

export default Splash;