import { useNavigate, useLocation } from "react-router-dom";
import { useState } from "react";
import avaLogo from "../assets/ava-logo.png";
import {
  MdDashboard,
  MdAssignment,
  MdLogout,
  MdChevronLeft,
  MdChevronRight,
} from "react-icons/md";

function Sidebar() {
  const navigate = useNavigate();
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);

  const menuItem = (label, icon, path) => (
    <div
      onClick={() => navigate(path)}
      style={{
        ...styles.menuItem,
        ...(location.pathname === path ? styles.activeItem : {}),
        justifyContent: collapsed ? "center" : "flex-start",
      }}
    >
      <span style={styles.icon}>{icon}</span>
      {!collapsed && <span>{label}</span>}
    </div>
  );

  return (
    <aside
      style={{
        ...styles.sidebar,
        width: collapsed ? "70px" : "220px",
      }}
    >
      {/* TOP */}
      <div>
        {/* Logo */}
        <div style={styles.logoContainer}>
          <img
            src={avaLogo}
            alt="AVA"
            style={{
              ...styles.logo,
              width: collapsed ? "40px" : "90px",
            }}
          />
        </div>

        {/* Menu */}
        <div style={styles.menu}>
          {menuItem("Dashboard", <MdDashboard />, "/dashboard")}
          {menuItem("Claims", <MdAssignment />, "/claims")}
        </div>
      </div>

      {/* BOTTOM */}
      <div>
        <div
          style={styles.menuItem}
          onClick={() => setCollapsed(!collapsed)}
        >
          <span style={styles.icon}>
            {collapsed ? <MdChevronRight /> : <MdChevronLeft />}
          </span>
          {!collapsed && <span>Collapse</span>}
        </div>

        <div
          style={styles.logout}
          onClick={() => navigate("/login")}
        >
          <span style={styles.icon}>
            <MdLogout />
          </span>
          {!collapsed && <span>Logout</span>}
        </div>
      </div>
    </aside>
  );
}

const styles = {
  sidebar: {
    height: "100vh",
    position: "fixed",
    left: 0,
    top: 0,
    background: "linear-gradient(180deg, #0f2027, #203a43, #2c5364)",
    display: "flex",
    flexDirection: "column",
    justifyContent: "space-between",
    padding: "20px 10px",
    transition: "width 0.3s ease",
    overflow: "hidden",
    boxShadow: "4px 0 15px rgba(0,0,0,0.35)",
  },
  logoContainer: {
    display: "flex",
    justifyContent: "center",
    marginBottom: "25px",
  },
  logo: {
    transition: "width 0.3s ease",
  },
  menu: {
    display: "flex",
    flexDirection: "column",
    gap: "8px",
  },
  menuItem: {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    padding: "12px",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "15px",
    fontWeight: "500",
    color: "#e6f6ff",
    transition: "background 0.25s ease",
  },
  activeItem: {
    background: "rgba(255,255,255,0.15)",
    fontWeight: "600",
  },
  icon: {
    fontSize: "20px",
    minWidth: "24px",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  },
  logout: {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    padding: "12px",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "15px",
    color: "#ffdddd",
    background: "rgba(0,0,0,0.25)",
    marginTop: "10px",
  },
};

export default Sidebar;