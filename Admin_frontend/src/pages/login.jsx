import { useState } from "react";
import { useNavigate } from "react-router-dom";

function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    setLoading(true);

    // Mock login (no validation, no errors)
    setTimeout(() => {
      navigate("/dashboard");
    }, 1500);
  };

  return (
    <div style={styles.page}>
      <div style={styles.card}>
        <h1 style={styles.title}>Insurance Admin Portal</h1>
        <p style={styles.subtitle}>Agent Login</p>

        <form onSubmit={handleLogin} style={styles.form}>
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            style={styles.input}
            required
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={styles.input}
            required
          />

          <button
            type="submit"
            style={{
              ...styles.button,
              opacity: loading ? 0.7 : 1,
              cursor: loading ? "not-allowed" : "pointer",
            }}
            disabled={loading}
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>
      </div>
    </div>
  );
}

const styles = {
  page: {
  position: "fixed",      
  inset: 0,               
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
},
  card: {
    background: "#ffffff",
    padding: "40px",
    width: "360px",
    borderRadius: "12px",
    boxShadow: "0 12px 35px rgba(0,0,0,0.25)",
    textAlign: "center",
  },
  title: {
    marginBottom: "6px",
    color: "#203a43",
  },
  subtitle: {
    marginBottom: "25px",
    color: "#666",
    fontSize: "14px",
  },
  form: {
    display: "flex",
    flexDirection: "column",
    gap: "14px",
  },
  input: {
    padding: "12px",
    fontSize: "14px",
    borderRadius: "6px",
    border: "1px solid #ccc",
  },
  button: {
    padding: "12px",
    fontSize: "15px",
    borderRadius: "6px",
    border: "none",
    background: "#203a43",
    color: "#fff",
    marginTop: "10px",
  },
};

export default Login;