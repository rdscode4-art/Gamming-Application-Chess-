import { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { 
  Users, UserPlus, Gamepad2, Trophy, 
  DollarSign, ArrowUpRight, ArrowDownRight, 
  Activity, Ticket, AlertCircle 
} from 'lucide-react';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  LineChart, Line
} from 'recharts';

const Dashboard = () => {
  const { token } = useAuth();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await axios.get('/api/auth/dashboard-stats', {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (response.data.status === 'success') {
          setStats(response.data.data);
        }
      } catch (error) {
        console.error('Failed to fetch dashboard stats', error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, [token]);

  if (loading || !stats) {
    return <div className="loading-state">Loading Analytics...</div>;
  }

  // Dummy data for charts (since we don't have historical timeseries yet)
  const revenueData = [
    { name: 'Mon', amount: stats.financials.totalRevenue * 0.1 },
    { name: 'Tue', amount: stats.financials.totalRevenue * 0.15 },
    { name: 'Wed', amount: stats.financials.totalRevenue * 0.2 },
    { name: 'Thu', amount: stats.financials.totalRevenue * 0.1 },
    { name: 'Fri', amount: stats.financials.totalRevenue * 0.25 },
    { name: 'Sat', amount: stats.financials.totalRevenue * 0.15 },
    { name: 'Sun', amount: stats.financials.totalRevenue * 0.05 },
  ];

  return (
    <div className="dashboard-container">
      <div className="page-header">
        <h1 className="page-title">Platform Analytics</h1>
        <p className="page-subtitle">Real-time overview of your chess platform</p>
      </div>

      {/* Financials Row */}
      <h2 className="section-title">Financial Overview</h2>
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Total Revenue</p>
              <h3 className="stat-value">₹{stats.financials.totalRevenue.toLocaleString()}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(34, 197, 94, 0.1)', color: '#22C55E' }}>
              <DollarSign size={24} />
            </div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Total Deposits</p>
              <h3 className="stat-value">₹{stats.financials.totalDeposits.toLocaleString()}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(59, 130, 246, 0.1)', color: '#3B82F6' }}>
              <ArrowUpRight size={24} />
            </div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Total Withdrawals</p>
              <h3 className="stat-value">₹{stats.financials.totalWithdrawals.toLocaleString()}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(229, 57, 53, 0.1)', color: '#E53935' }}>
              <ArrowDownRight size={24} />
            </div>
          </div>
        </div>
      </div>

      {/* Users & Engagement Row */}
      <h2 className="section-title" style={{ marginTop: '32px' }}>Users & Engagement</h2>
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Total Users</p>
              <h3 className="stat-value">{stats.users.total.toLocaleString()}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(245, 166, 35, 0.1)', color: '#F5A623' }}>
              <Users size={24} />
            </div>
          </div>
          <p className="stat-footer">
            <span style={{ color: '#22C55E' }}>+{stats.users.newLast7Days}</span> in last 7 days
          </p>
        </div>

        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Registered vs Guests</p>
              <h3 className="stat-value">{stats.users.registered} / {stats.users.guests}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(108, 63, 197, 0.1)', color: '#6C3FC5' }}>
              <UserPlus size={24} />
            </div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-header">
            <div>
              <p className="stat-label">Total Games Played</p>
              <h3 className="stat-value">{stats.engagement.totalGames.toLocaleString()}</h3>
            </div>
            <div className="stat-icon-wrapper" style={{ background: 'rgba(59, 130, 246, 0.1)', color: '#3B82F6' }}>
              <Gamepad2 size={24} />
            </div>
          </div>
          <p className="stat-footer">
            <span style={{ color: '#F5A623' }}>{stats.engagement.liveGames}</span> active live games
          </p>
        </div>
      </div>

      {/* Charts & Operations */}
      <div className="charts-grid" style={{ marginTop: '32px', display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        <div className="glass-panel" style={{ padding: '24px' }}>
          <h3 className="section-title" style={{ marginTop: 0, marginBottom: '24px' }}>Revenue Overview (Last 7 Days)</h3>
          <div style={{ height: '300px', width: '100%' }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenueData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" vertical={false} />
                <XAxis dataKey="name" stroke="#8A94A6" axisLine={false} tickLine={false} />
                <YAxis stroke="#8A94A6" axisLine={false} tickLine={false} tickFormatter={(val) => `₹${val}`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#070D18', border: '1px solid rgba(255,255,255,0.1)', borderRadius: '8px' }}
                  itemStyle={{ color: '#F5A623' }}
                />
                <Bar dataKey="amount" fill="#F5A623" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div className="stat-card">
            <div className="stat-header">
              <div>
                <p className="stat-label">Pending Withdrawals</p>
                <h3 className="stat-value">{stats.operations.pendingWithdrawals}</h3>
              </div>
              <div className="stat-icon-wrapper" style={{ background: 'rgba(229, 57, 53, 0.1)', color: '#E53935' }}>
                <AlertCircle size={24} />
              </div>
            </div>
            {stats.operations.pendingWithdrawals > 0 && (
              <p className="stat-footer" style={{ color: '#E53935' }}>Action required</p>
            )}
          </div>

          <div className="stat-card">
            <div className="stat-header">
              <div>
                <p className="stat-label">Open Support Tickets</p>
                <h3 className="stat-value">{stats.operations.pendingTickets}</h3>
              </div>
              <div className="stat-icon-wrapper" style={{ background: 'rgba(59, 130, 246, 0.1)', color: '#3B82F6' }}>
                <Ticket size={24} />
              </div>
            </div>
          </div>
          
          <div className="stat-card">
            <div className="stat-header">
              <div>
                <p className="stat-label">Total Tournaments</p>
                <h3 className="stat-value">{stats.engagement.totalTournaments}</h3>
              </div>
              <div className="stat-icon-wrapper" style={{ background: 'rgba(245, 166, 35, 0.1)', color: '#F5A623' }}>
                <Trophy size={24} />
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  );
};

export default Dashboard;
