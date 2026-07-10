import { useState, useEffect } from 'react';
import axios from 'axios';
import { Ban, Edit2, CheckCircle } from 'lucide-react';

const API_URL = 'http://localhost:7893/api/admin/users';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [walletData, setWalletData] = useState({ depositBalance: 0, winningsBalance: 0, bonusBalance: 0 });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const { data } = await axios.get(API_URL);
      setUsers(data);
    } catch (error) {
      console.error('Failed to fetch users', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleWalletSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.put(`${API_URL}/${selectedUser._id}/wallet`, walletData);
      setIsModalOpen(false);
      fetchUsers();
    } catch (error) {
      console.error('Failed to update wallet', error);
    }
  };

  const handleToggleBan = async (id, isCurrentlyBanned) => {
    const action = isCurrentlyBanned ? 'UNBAN' : 'BAN';
    if (confirm(`Are you sure you want to ${action} this user?`)) {
      await axios.put(`${API_URL}/${id}/ban`);
      fetchUsers();
    }
  };

  const openWalletModal = (user) => {
    setSelectedUser(user);
    setWalletData({
      depositBalance: user.depositBalance || 0,
      winningsBalance: user.winningsBalance || 0,
      bonusBalance: user.bonusBalance || 0
    });
    setIsModalOpen(true);
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Users & Wallet</h1>
      </div>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>User</th>
              <th>Status / Rating</th>
              <th>Wallet Balance (D/W/B)</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading...</td></tr>
            ) : users.map((user) => (
              <tr key={user._id}>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{
                      width: '40px', height: '40px', borderRadius: '50%', 
                      background: 'var(--primary-gold)', color: '#000',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontWeight: 'bold', fontSize: '18px'
                    }}>
                      {user.username.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <div style={{ fontWeight: 'bold', fontSize: '16px', color: 'var(--text-light)' }}>{user.username}</div>
                      <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{user.email || user.phoneNumber || 'No Email'}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span className={`badge ${user.isBanned ? 'inactive' : 'active'}`}>
                      {user.isBanned ? 'BANNED' : 'ACTIVE'}
                    </span>
                    <span style={{ fontSize: '14px', color: 'var(--text-muted)', fontWeight: '500' }}>
                      {user.rating} ELO
                    </span>
                  </div>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '12px', fontSize: '14px' }}>
                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                      <span style={{ color: 'var(--text-muted)', fontSize: '11px' }}>DEPOSIT</span>
                      <span style={{ fontWeight: '600' }}>₹{user.depositBalance || 0}</span>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                      <span style={{ color: 'var(--text-muted)', fontSize: '11px' }}>WINNINGS</span>
                      <span style={{ fontWeight: '600', color: 'var(--accent-green)' }}>₹{user.winningsBalance || 0}</span>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column' }}>
                      <span style={{ color: 'var(--text-muted)', fontSize: '11px' }}>TOTAL</span>
                      <span style={{ fontWeight: 'bold', color: 'var(--primary-gold)' }}>
                        ₹{(user.depositBalance || 0) + (user.winningsBalance || 0) + (user.bonusBalance || 0)}
                      </span>
                    </div>
                  </div>
                </td>
                <td>{new Date(user.createdAt).toLocaleDateString()}</td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="glass-button" onClick={() => openWalletModal(user)} title="Edit Wallet">
                      <Edit2 size={16} />
                    </button>
                    <button 
                      className="glass-button" 
                      onClick={() => handleToggleBan(user._id, user.isBanned)}
                      title={user.isBanned ? "Unban User" : "Ban User"}
                    >
                      {user.isBanned ? <CheckCircle size={16} color="var(--accent-green)" /> : <Ban size={16} color="var(--accent-red)" />}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isModalOpen && (
        <div className="modal-overlay" onClick={() => setIsModalOpen(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">Edit Wallet: {selectedUser?.username}</h2>
            </div>
            
            <form onSubmit={handleWalletSubmit}>
              <div className="form-group">
                <label className="form-label">Deposit Balance (₹)</label>
                <input type="number" className="glass-input" value={walletData.depositBalance} onChange={e => setWalletData({...walletData, depositBalance: Number(e.target.value)})} required />
              </div>
              <div className="form-group">
                <label className="form-label">Winnings Balance (₹)</label>
                <input type="number" className="glass-input" value={walletData.winningsBalance} onChange={e => setWalletData({...walletData, winningsBalance: Number(e.target.value)})} required />
              </div>
              <div className="form-group">
                <label className="form-label">Bonus Balance (₹)</label>
                <input type="number" className="glass-input" value={walletData.bonusBalance} onChange={e => setWalletData({...walletData, bonusBalance: Number(e.target.value)})} required />
              </div>

              <div className="form-actions">
                <button type="button" className="glass-button" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="glass-button primary">Update Wallet</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Users;
