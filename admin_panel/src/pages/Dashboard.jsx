import { useState, useEffect } from 'react';
import axios from 'axios';

const Dashboard = () => {
  const [stats, setStats] = useState({ modes: 0, tournaments: 0, banners: 0 });

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const [modesRes, tourneysRes, bannersRes] = await Promise.all([
          axios.get('http://localhost:7893/api/admin/gamemodes'),
          axios.get('http://localhost:7893/api/admin/tournaments'),
          axios.get('http://localhost:7893/api/admin/banners')
        ]);
        setStats({
          modes: modesRes.data.length,
          tournaments: tourneysRes.data.length,
          banners: bannersRes.data.length
        });
      } catch (error) {
        console.error('Failed to fetch stats', error);
      }
    };
    fetchStats();
  }, []);

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
      </div>
      
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '24px' }}>
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h3 style={{ color: 'var(--text-muted)', marginBottom: '8px' }}>Total Game Modes</h3>
          <p style={{ fontSize: '32px', fontWeight: 'bold', color: 'var(--primary-gold)' }}>{stats.modes}</p>
        </div>
        
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h3 style={{ color: 'var(--text-muted)', marginBottom: '8px' }}>Active Tournaments</h3>
          <p style={{ fontSize: '32px', fontWeight: 'bold', color: 'var(--primary-gold)' }}>{stats.tournaments}</p>
        </div>
        
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h3 style={{ color: 'var(--text-muted)', marginBottom: '8px' }}>Active Banners</h3>
          <p style={{ fontSize: '32px', fontWeight: 'bold', color: 'var(--primary-gold)' }}>{stats.banners}</p>
        </div>
      </div>
      
      <div style={{ marginTop: '32px' }} className="glass-panel">
        <div style={{ padding: '24px', borderBottom: '1px solid var(--border-color)' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 'bold' }}>Quick Actions</h2>
        </div>
        <div style={{ padding: '24px', display: 'flex', gap: '16px' }}>
          <button className="glass-button primary">Create Tournament</button>
          <button className="glass-button">Add Game Mode</button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
