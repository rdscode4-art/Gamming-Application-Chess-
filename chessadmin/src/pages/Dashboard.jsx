import { useState, useEffect } from 'react';
import axios from 'axios';
import { useTheme } from '../context/ThemeContext';
import { Gamepad2, Trophy, Image, Sun, Moon, Plus, ChevronRight, Activity } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const [stats, setStats] = useState({ modes: 0, tournaments: 0, banners: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const { theme, toggleTheme } = useTheme();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [modesRes, tourneysRes, bannersRes] = await Promise.all([
          axios.get('https://chessback.ridealdigitalseva.com/api/admin/gamemodes'),
          axios.get('https://chessback.ridealdigitalseva.com/api/admin/tournaments'),
          axios.get('https://chessback.ridealdigitalseva.com/api/admin/banners')
        ]);
        setStats({
          modes: modesRes.data.length,
          tournaments: tourneysRes.data.length,
          banners: bannersRes.data.length
        });
      } catch (error) {
        console.error('Failed to fetch stats', error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchStats();
  }, []);

  const statCards = [
    { title: 'Total Game Modes', value: stats.modes, icon: <Gamepad2 size={24} />, color: '#3B82F6', path: '/gamemodes' },
    { title: 'Active Tournaments', value: stats.tournaments, icon: <Trophy size={24} />, color: '#10B981', path: '/tournaments' },
    { title: 'Active Banners', value: stats.banners, icon: <Image size={24} />, color: '#F59E0B', path: '/banners' }
  ];

  return (
    <div className="page-container" style={{ animation: 'fadeIn 0.3s ease-out' }}>
      <div className="page-header" style={{ marginBottom: '40px' }}>
        <div>
          <h1 className="page-title">Welcome back, Admin 👋</h1>
          <p className="page-subtitle">Here is what's happening with your platform today.</p>
        </div>
        
        {/* Theme Toggle Button in Header */}
        <button 
          onClick={toggleTheme}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '10px 16px',
            backgroundColor: 'var(--bg-card)',
            color: 'var(--text-light)',
            border: '1px solid var(--border-color)',
            borderRadius: '50px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: '600',
            transition: 'all 0.3s ease',
            boxShadow: 'var(--shadow-sm)'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'translateY(-2px)';
            e.currentTarget.style.boxShadow = 'var(--shadow-lg)';
            e.currentTarget.style.borderColor = 'var(--primary-gold)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = 'var(--shadow-sm)';
            e.currentTarget.style.borderColor = 'var(--border-color)';
          }}
        >
          {theme === 'light' ? <Sun size={18} color="#F59E0B" /> : <Moon size={18} color="#8B5CF6" />}
          {theme === 'light' ? 'Light Mode' : 'Dark Mode'}
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '24px', marginBottom: '40px' }}>
        {statCards.map((card, index) => (
          <div 
            key={index}
            className="glass-panel" 
            style={{ 
              padding: '24px',
              display: 'flex',
              flexDirection: 'column',
              position: 'relative',
              overflow: 'hidden',
              cursor: 'pointer'
            }}
            onClick={() => navigate(card.path)}
            onMouseEnter={(e) => e.currentTarget.style.transform = 'translateY(-4px)'}
            onMouseLeave={(e) => e.currentTarget.style.transform = 'translateY(0)'}
          >
            <div style={{
              position: 'absolute',
              top: '-20px',
              right: '-20px',
              width: '100px',
              height: '100px',
              borderRadius: '50%',
              background: `radial-gradient(circle, ${card.color}33 0%, transparent 70%)`,
              zIndex: 0
            }}></div>
            
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', zIndex: 1 }}>
              <div style={{ 
                padding: '12px', 
                borderRadius: '12px', 
                backgroundColor: `${card.color}15`,
                color: card.color
              }}>
                {card.icon}
              </div>
              <ChevronRight size={20} color="var(--text-muted)" style={{ opacity: 0.5 }} />
            </div>
            
            <h3 style={{ color: 'var(--text-muted)', fontSize: '14px', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '8px', zIndex: 1 }}>
              {card.title}
            </h3>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: '12px', zIndex: 1 }}>
              <p style={{ fontSize: '36px', fontWeight: '800', color: 'var(--text-light)', lineHeight: 1 }}>
                {isLoading ? '...' : card.value}
              </p>
            </div>
          </div>
        ))}
      </div>

      <div className="glass-panel" style={{ position: 'relative', overflow: 'hidden' }}>
        <div style={{
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '4px',
          background: 'linear-gradient(90deg, var(--primary-gold), var(--accent-blue))'
        }}></div>
        
        <div style={{ padding: '24px 32px', borderBottom: '1px solid var(--border-color)', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <Activity size={20} color="var(--primary-gold)" />
          <h2 style={{ fontSize: '18px', fontWeight: 'bold' }}>Quick Actions</h2>
        </div>
        
        <div style={{ padding: '32px', display: 'flex', flexWrap: 'wrap', gap: '16px' }}>
          <button className="primary-btn" onClick={() => navigate('/tournaments')} style={{ padding: '12px 24px' }}>
            <Plus size={18} /> Create Tournament
          </button>
          <button className="glass-button" onClick={() => navigate('/gamemodes')} style={{ padding: '12px 24px', fontSize: '15px' }}>
            <Plus size={18} /> Add Game Mode
          </button>
          <button className="glass-button" onClick={() => navigate('/guides')} style={{ padding: '12px 24px', fontSize: '15px' }}>
            <Plus size={18} /> Write Guide
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
