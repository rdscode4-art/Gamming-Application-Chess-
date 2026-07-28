import { NavLink, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Gamepad2, Trophy, Image, Users, Settings, Headset, Bell, Banknote, LogOut } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const Sidebar = () => {
  const { logout } = useAuth();
  const navigate = useNavigate();

  return (
    <aside className="sidebar" style={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      <div className="sidebar-brand">
        CHESS ADMIN
      </div>
      
      <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <NavLink to="/" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <LayoutDashboard size={20} />
          Dashboard
        </NavLink>
        
        <NavLink to="/gamemodes" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Gamepad2 size={20} />
          Game Modes
        </NavLink>

        <NavLink to="/tournaments" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Trophy size={20} />
          Tournaments
        </NavLink>

        <NavLink to="/banners" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Image size={20} />
          Banners
        </NavLink>

        <NavLink to="/users" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Users size={20} />
          Users & Wallet
        </NavLink>

        <NavLink to="/withdrawals" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Banknote size={20} />
          Withdrawals
        </NavLink>

        <NavLink to="/settings" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Settings size={20} />
          Settings
        </NavLink>

        <NavLink to="/support" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Headset size={20} />
          Support Tickets
        </NavLink>

        <NavLink to="/notifications" className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}>
          <Bell size={20} />
          Notifications
        </NavLink>
      </nav>

      <div style={{ marginTop: 'auto', padding: '16px' }}>
        <button 
          onClick={() => {
            logout();
            navigate('/login');
          }}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            width: '100%',
            padding: '12px 16px',
            backgroundColor: 'rgba(229, 57, 53, 0.1)',
            color: '#E53935',
            border: 'none',
            borderRadius: '12px',
            cursor: 'pointer',
            fontSize: '15px',
            fontWeight: '600'
          }}
        >
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
