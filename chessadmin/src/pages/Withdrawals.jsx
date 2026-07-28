import { useState, useEffect } from 'react';
import axios from 'axios';
import { CheckCircle, XCircle, Clock, Copy } from 'lucide-react';

const API_URL = '/api/admin/withdrawals';

const Withdrawals = () => {
  const [withdrawals, setWithdrawals] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchWithdrawals();
  }, []);

  const fetchWithdrawals = async () => {
    try {
      const { data } = await axios.get(API_URL);
      setWithdrawals(data);
    } catch (error) {
      console.error('Failed to fetch withdrawals', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleStatusChange = async (id, status) => {
    if (!confirm(`Are you sure you want to mark this request as ${status.toUpperCase()}?`)) return;
    
    try {
      await axios.put(`${API_URL}/${id}`, { status });
      fetchWithdrawals();
    } catch (error) {
      alert('Failed to update status');
      console.error(error);
    }
  };

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    alert('Copied to clipboard');
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Withdrawal Requests</h1>
      </div>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>User</th>
              <th>Amount</th>
              <th>Details</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="6" style={{ textAlign: 'center' }}>Loading...</td></tr>
            ) : withdrawals.length === 0 ? (
              <tr><td colSpan="6" style={{ textAlign: 'center' }}>No withdrawal requests found.</td></tr>
            ) : withdrawals.map((tx) => (
              <tr key={tx._id}>
                <td>
                  <div style={{ color: 'var(--text-light)', fontSize: '14px' }}>
                    {new Date(tx.createdAt).toLocaleDateString()}
                  </div>
                  <div style={{ color: 'var(--text-muted)', fontSize: '12px' }}>
                    {new Date(tx.createdAt).toLocaleTimeString()}
                  </div>
                </td>
                <td>
                  <div style={{ fontWeight: 'bold', fontSize: '15px', color: 'var(--text-light)' }}>
                    {tx.user?.username || 'Unknown'}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                    {tx.user?.phone || tx.userId}
                  </div>
                </td>
                <td>
                  <span style={{ color: 'var(--primary-gold)', fontWeight: 'bold', fontSize: '16px' }}>
                    ₹{tx.amount}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '13px', color: 'var(--text-light)' }}>
                    {tx.description}
                    <button 
                      onClick={() => copyToClipboard(tx.description)}
                      style={{ background: 'none', border: 'none', color: 'var(--primary-gold)', cursor: 'pointer', padding: 0 }}
                      title="Copy Details"
                    >
                      <Copy size={14} />
                    </button>
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>
                    Txn ID: {tx.transactionId}
                  </div>
                </td>
                <td>
                  <span className={`badge ${tx.status === 'completed' ? 'active' : tx.status === 'failed' ? 'inactive' : 'pending'}`} style={{ display: 'flex', alignItems: 'center', gap: '4px', width: 'fit-content' }}>
                    {tx.status === 'completed' && <CheckCircle size={12} />}
                    {tx.status === 'failed' && <XCircle size={12} />}
                    {tx.status === 'pending' && <Clock size={12} />}
                    {tx.status.toUpperCase()}
                  </span>
                </td>
                <td>
                  {tx.status === 'pending' ? (
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        className="btn btn-primary" 
                        style={{ padding: '6px 12px', fontSize: '12px' }}
                        onClick={() => handleStatusChange(tx._id, 'completed')}
                      >
                        Approve
                      </button>
                      <button 
                        className="btn btn-danger" 
                        style={{ padding: '6px 12px', fontSize: '12px', background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.2)' }}
                        onClick={() => handleStatusChange(tx._id, 'failed')}
                      >
                        Reject
                      </button>
                    </div>
                  ) : (
                    <span style={{ color: 'var(--text-muted)', fontSize: '12px' }}>Processed</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Withdrawals;
