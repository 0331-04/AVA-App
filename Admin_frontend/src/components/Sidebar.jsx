import { useLocation, useNavigate } from "react-router-dom";
import avaLogo from "../assets/ava-logo.png"; // make sure this path is correct

function Sidebar() {
  const navigate = useNavigate();
  const location = useLocation();

  const isActive = (path) => {
    if (path === "/claims") {
      return location.pathname.startsWith("/claims");
    }
    return location.pathname === path;
  };

  const handleLogout = () => {
    // frontend-only logout for now
    localStorage.removeItem("auth");
    navigate("/login");
  };

  return (
    <aside style={styles.sidebar}>
      {/* Logo */}
      <div style={styles.logoContainer}>
        <img src={avaLogo} alt="AVA Logo" style={styles.logo} />
      </div>

      {/* Navigation */}
      <nav style={styles.nav}>
        <SidebarItem
          label="Dashboard"
          active={isActive("/dashboard")}
          onClick={() => navigate("/dashboard")}
        />

        <SidebarItem
          label="Claims"
          active={isActive("/claims")}
          onClick={() => navigate("/claims")}
        />
      </nav>

      {/* Logout */}
      <div style={styles.logoutContainer}>
        <button style={styles.logoutBtn} onClick={handleLogout}>
          Logout
        </button>
      </div>
    </aside>
  );
}


function SidebarItem({ label, active, onClick }) {
  return (
    <div
      onClick={onClick}
      style={{
        ...styles.item,
        ...(active ? styles.activeItem : {}),
      }}
    >
      {label}
    </div>
  );
}


const styles = {
  sidebar: {
    width: "220px",
    minHeight: "100vh",
    background: "linear-gradient(180deg, #0f2027, #203a43)",
    padding: "20px",
    position: "fixed",
    left: 0,
    top: 0,
    display: "flex",
    flexDirection: "column",
    color: "#fff",
  },

  logoContainer: {
    display: "flex",
    justifyContent: "center",
    marginBottom: "40px",
  },

  logo: {
    width: "140px",
    objectFit: "contain",
  },

  nav: {
    display: "flex",
    flexDirection: "column",
    gap: "8px",
    flex: 1,
  },

  item: {
    padding: "12px 16px",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "500",
    color: "#cfe9f5",
    transition: "all 0.25s ease",
  },

  activeItem: {
    background: "rgba(0, 224, 255, 0.15)",
    color: "#00e0ff",
    fontWeight: "600",
  },

  logoutContainer: {
    marginTop: "auto",
  },

  logoutBtn: {
    width: "100%",
    padding: "10px",
    background: "rgba(255,255,255,0.08)",
    border: "none",
    borderRadius: "10px",
    color: "#fff",
    cursor: "pointer",
    fontWeight: "500",
  },
};

export default Sidebar;