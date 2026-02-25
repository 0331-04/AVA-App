import { NavLink } from "react-router-dom";
import {
  MdDashboard,
  MdDescription,
  MdLogout,
  MdMenu,
} from "react-icons/md";

import logo from "../assets/ava-logo-full.png";

function Sidebar({ collapsed, setCollapsed }) {
  return (
    <aside style={{ ...styles.sidebar, width: collapsed ? "70px" : "220px" }}>
      
      {/* Logo + Toggle */}
      <div style={styles.top}>
        {!collapsed && (
          <img
            src={logo}
            alt="AVA Insurance"
            style={styles.logo}
          />
        )}

        <button
          onClick={() => setCollapsed(!collapsed)}
          style={styles.toggle}
          title="Toggle sidebar"
        >
          <MdMenu size={22} />
        </button>
      </div>

      {/* Navigation */}
      <nav style={styles.nav}>
        <NavItem
          to="/dashboard"
          icon={<MdDashboard size={22} />}
          label="Dashboard"
          collapsed={collapsed}
        />

        <NavItem
          to="/claims"
          icon={<MdDescription size={22} />}
          label="Claims"
          collapsed={collapsed}
        />
      </nav>

      {/* Footer */}
      <div style={styles.footer}>
        <NavItem
          to="/login"
          icon={<MdLogout size={22} />}
          label="Logout"
          collapsed={collapsed}
        />
      </div>
    </aside>
  );
}

/* 🔹 Single Nav Item */
function NavItem({ to, icon, label, collapsed }) {
  return (
    <NavLink
      to={to}
      style={({ isActive }) => ({
        ...styles.link,
        background: isActive ? "rgba(0,224,255,0.15)" : "transparent",
      })}
      title={collapsed ? label : undefined}
    >
      <span style={styles.icon}>{icon}</span>
      {!collapsed && <span>{label}</span>}
    </NavLink>
  );
}

/* 🎨 Styles */
const styles = {
  sidebar: {
    position: "fixed",
    top: 0,
    left: 0,
    height: "100vh",
    background: "linear-gradient(180deg, #0f2027, #203a43)",
    padding: "16px 12px",
    boxShadow: "4px 0 20px rgba(0,0,0,0.3)",
    transition: "width 0.3s ease",
    display: "flex",
    flexDirection: "column",
    zIndex: 100,
  },

  top: {
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: "30px",
  },

  logo: {
    width: "130px",
    objectFit: "contain",
  },

  toggle: {
    background: "transparent",
    border: "none",
    color: "#00e0ff",
    cursor: "pointer",
  },

  nav: {
    display: "flex",
    flexDirection: "column",
    gap: "8px",
  },

  footer: {
    marginTop: "auto",
  },

  link: {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    padding: "10px 12px",
    borderRadius: "10px",
    color: "#e6f6ff",
    textDecoration: "none",
    fontSize: "15px",
    transition: "background 0.2s",
  },

  icon: {
    minWidth: "24px",
    display: "flex",
    justifyContent: "center",
  },
};

export default Sidebar;