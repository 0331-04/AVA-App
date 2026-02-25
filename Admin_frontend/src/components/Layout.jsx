import { useState } from "react";
import Sidebar from "./Sidebar";

function Layout({ children }) {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <>
      <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />

      <main
        style={{
          marginLeft: collapsed ? "70px" : "220px",
          transition: "margin-left 0.3s ease",
          minHeight: "100vh",
        }}
      >
        {children}
      </main>
    </>
  );
}

export default Layout;