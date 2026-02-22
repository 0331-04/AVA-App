import { useEffect } from "react";
import { useNavigate } from "react-router-dom";

function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/");
    }, 2000); // 2 seconds splash

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div style={styles.container}>
      <div style={styles.content}>
        <h1 style={styles.logo}>AVA</h1>
        <p style={styles.tagline}>Where every claim meets clarity</p>

        <div style={styles.loaderContainer}>
          <div style={styles.loader}></div>
        </div>

        <p style={styles.loadingText}>Loading</p>
      </div>
    </div>
  );
}

const styles = {
  container: {
    height: "100vh",
    width: "100vw",
    background: "#0b4fa2",
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    color: "#fff",
  },
  content: {
    textAlign: "center",
  },
  logo: {
    fontSize: "48px",
    fontWeight: "bold",
    marginBottom: "10px",
  },
  tagline: {
    fontSize: "16px",
    marginBottom: "40px",
    opacity: 0.9,
  },
  loaderContainer: {
    width: "200px",
    height: "6px",
    background: "rgba(255,255,255,0.3)",
    borderRadius: "10px",
    overflow: "hidden",
    margin: "0 auto",
  },
  loader: {
    width: "50%",
    height: "100%",
    background: "#00e0ff",
    animation: "load 2s linear",
  },
  loadingText: {
    marginTop: "12px",
    fontSize: "14px",
    opacity: 0.9,
  },
};

export default Splash;