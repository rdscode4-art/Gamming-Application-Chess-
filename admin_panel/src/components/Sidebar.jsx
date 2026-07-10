import { NavLink } from 'react-router-dom';
import { LayoutDashboard, Gamepad2, Trophy, Image, Users } from 'lucide-react';

const Sidebar = () => {
  return (
    <aside className="sidebar">
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
      </nav>
    </aside>
  );
};

export default Sidebar;
