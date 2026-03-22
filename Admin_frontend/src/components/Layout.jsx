import { useState } from "react";
import Sidebar from "./Sidebar";
import Topbar from "./Topbar";

function Layout({ children, title }) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <>
      <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />

      <main
        style={{
          marginLeft: collapsed ? "70px" : "220px",
          transition: "margin-left 0.3s ease",
          minHeight: "100vh",
          background: "transparent", // 🔥 FIXED
        }}
      >
        <Topbar title={title} />

        <div style={{ padding: "24px" }}>
          {children}
        </div>
      </main>
    </>
  );
}

export default Layout;