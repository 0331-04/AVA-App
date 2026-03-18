import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

console.log("LOGIN COMPONENT LOADED 🚀");

function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const navigate = useNavigate();
  const { login } = useAuth();

  const handleLogin = (e) => {
    e.preventDefault();

    const cleanEmail = email.trim().toLowerCase();

    console.log("===== AUTH DEBUG =====");
    console.log("CLEAN EMAIL:", cleanEmail);

    if (
      cleanEmail === "demo_admin@gmail.com" ||
      cleanEmail === "demo_agent@gmail.com" ||
      cleanEmail === "demo_viewer@gmail.com"
    ) {
      login(cleanEmail);
      navigate("/dashboard");
    } else {
      setError("Invalid email or password");
    }
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
            onChange={(e) => {
              setEmail(e.target.value);
              setError("");
            }}
            style={styles.input}
            required
          />

          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => {
              setPassword(e.target.value);
              setError("");
            }}
            style={styles.input}
            required
          />

          {error && <p style={styles.error}>{error}</p>}

          <button type="submit" style={styles.button}>
            Login
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
    background: "linear-gradient(135deg,#0f2027,#203a43,#2c5364)",
  },
  card: {
    background: "#ffffff",
    padding: "40px",
    width: "360px",
    borderRadius: "12px",
    boxShadow: "0 12px 35px rgba(0,0,0,0.25)",
    textAlign: "center",
  },
  title: { marginBottom: "6px", color: "#203a43" },
  subtitle: { marginBottom: "25px", color: "#666", fontSize: "14px" },
  form: { display: "flex", flexDirection: "column", gap: "14px" },
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
    cursor: "pointer",
  },
  error: {
    color: "#c0392b",
    fontSize: "13px",
    marginTop: "-6px",
  },
};

export default Login;