import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import logo from "../assets/ava-logo-full.png";

function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/login");
    }, 2500);

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
    background: "#0a4fb3", // SAME blue tone as your image
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
    width: "180px",
    height: "180px",
    
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
    background: "#00e0ff",
    animation: "load 2.5s linear",
  },
  loadingText: {
    marginTop: "14px",
    color: "#ffffff",
    fontSize: "14px",
    opacity: 0.9,
  },
};

export default Splash;