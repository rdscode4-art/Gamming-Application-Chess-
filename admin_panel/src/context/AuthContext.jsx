import { createContext, useState, useEffect, useContext } from 'react';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [admin, setAdmin] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check local storage on mount
    const storedToken = localStorage.getItem('adminToken');
    const storedAdmin = localStorage.getItem('adminData');
    
    if (storedToken && storedAdmin) {
      setToken(storedToken);
      setAdmin(JSON.parse(storedAdmin));
    }
    setLoading(false);
  }, []);

  const login = (userData, jwtToken) => {
    setAdmin(userData);
    setToken(jwtToken);
    localStorage.setItem('adminToken', jwtToken);
    localStorage.setItem('adminData', JSON.stringify(userData));
  };

  const logout = () => {
    setAdmin(null);
    setToken(null);
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminData');
  };

  if (loading) {
    return <div style={{ display: 'flex', height: '100vh', justifyContent: 'center', alignItems: 'center', backgroundColor: '#0B1220', color: 'white' }}>Loading...</div>;
  }

  return (
    <AuthContext.Provider value={{ admin, token, login, logout, isAuthenticated: !!token }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
