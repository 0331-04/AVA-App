import { createContext, useContext, useState } from "react";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  const login = (email) => {
    let role = "viewer";

    if (email === "demo_admin@gmail.com") role = "admin";
    else if (email === "demo_agent@gmail.com") role = "agent";
    else if (email === "demo_viewer@gmail.com") role = "viewer";

    setUser({ email, role });
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// ✅ THIS IS THE IMPORTANT PART
export const useAuth = () => {
  return useContext(AuthContext);
};