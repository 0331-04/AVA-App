import { useState } from "react";
import { useAuth } from "../context/AuthContext";

function Topbar({ title }) {
  const { user, logout } = useAuth();
  const [open, setOpen] = useState(false);

  // 🔥 SAFE FALLBACKS
  const role = user?.role || "Admin";
  const initial = role.charAt(0).toUpperCase();

  return (
    <div style={styles.topbar}>
      
      {/* LEFT */}
      <h2 style={styles.title}>{title}</h2>

      {/* RIGHT */}
      <div style={styles.right}>
        
        <div
          style={styles.profile}
          onClick={() => setOpen(!open)}
        >
          <div style={styles.avatar}>
            {initial}
          </div>

          <span style={styles.name}>
            {role}
          </span>
        </div>

        {open && (
          <div style={styles.dropdown}>
            <p style={styles.dropdownItem}>
              Role: <b>{role}</b>
            </p>

            <div style={styles.divider} />

            <p style={styles.logout} onClick={logout}>
              Logout
            </p>
          </div>
        )}

      </div>

    </div>
  );
}

const styles = {
  topbar: {
    height: "60px",
    background: "linear-gradient(135deg, #0f2027, #203a43)",
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    padding: "0 24px",
    borderBottom: "1px solid rgba(255,255,255,0.1)",
    position: "sticky",
    top: 0,
    zIndex: 999,
  },

  title: {
    fontSize: "22px",
    fontWeight: "600",
    color: "#ffffff",
  },

  right: {
    position: "relative",
  },

  profile: {
    display: "flex",
    alignItems: "center",
    gap: "10px",
    cursor: "pointer",
  },

  avatar: {
    width: "38px",
    height: "38px",
    borderRadius: "50%",
    background: "#00e0ff",
    color: "#000",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "700",
    fontSize: "16px",
  },

  name: {
    fontSize: "14px",
    color: "#e6f6ff",
    textTransform: "capitalize",
  },

  dropdown: {
    position: "absolute",
    right: 0,
    top: "55px",
    width: "180px",
    background: "#203a43",
    border: "1px solid rgba(255,255,255,0.1)",
    borderRadius: "12px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.5)",
    padding: "12px",
    zIndex: 1000,
  },

  dropdownItem: {
    fontSize: "14px",
    marginBottom: "10px",
    color: "#e6f6ff",
  },

  divider: {
    height: "1px",
    background: "rgba(255,255,255,0.1)",
    margin: "8px 0",
  },

  logout: {
    fontSize: "14px",
    color: "#ff6b6b",
    cursor: "pointer",
  },
};

export default Topbar;