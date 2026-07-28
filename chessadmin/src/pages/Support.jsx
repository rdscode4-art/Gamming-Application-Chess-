import { useState, useEffect } from 'react';
import axios from 'axios';
import { Headset, CheckCircle, Clock, XCircle, Send } from 'lucide-react';

const API_URL = '/api/admin/support';
const ADMIN_TOKEN = localStorage.getItem('adminToken') || '';

function Support() {
  const [tickets, setTickets] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedTicket, setSelectedTicket] = useState(null);
  const [replyMessage, setReplyMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchTickets();
  }, []);

  const fetchTickets = async () => {
    setIsLoading(true);
    try {
      const { data } = await axios.get(API_URL, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      setTickets(data.tickets || []);
    } catch (error) {
      console.error('Error fetching tickets:', error);
    }
    setIsLoading(false);
  };

  const fetchTicketDetails = async (id) => {
    try {
      const { data } = await axios.get(`${API_URL}/${id}`, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      setSelectedTicket(data.ticket);
    } catch (error) {
      console.error('Error fetching ticket details:', error);
    }
  };

  const handleStatusChange = async (ticketId, newStatus) => {
    try {
      await axios.put(`${API_URL}/${ticketId}/status`, { status: newStatus }, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      fetchTickets();
      if (selectedTicket && selectedTicket._id === ticketId) {
        setSelectedTicket({ ...selectedTicket, status: newStatus });
      }
    } catch (error) {
      console.error('Error updating status:', error);
    }
  };

  const handleReply = async () => {
    if (!replyMessage.trim()) return;
    setIsSubmitting(true);
    try {
      const { data } = await axios.post(`${API_URL}/${selectedTicket._id}/reply`, {
        message: replyMessage
      }, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      setReplyMessage('');
      setSelectedTicket(data.ticket);
      fetchTickets(); // Refresh list to update status
    } catch (error) {
      console.error('Error sending reply:', error);
    }
    setIsSubmitting(false);
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'open':
        return <span className="badge" style={{ backgroundColor: '#FF9800', color: 'white' }}>Open</span>;
      case 'in_progress':
        return <span className="badge" style={{ backgroundColor: '#2196F3', color: 'white' }}>In Progress</span>;
      case 'resolved':
        return <span className="badge" style={{ backgroundColor: '#4CAF50', color: 'white' }}>Resolved</span>;
      case 'closed':
        return <span className="badge" style={{ backgroundColor: '#9E9E9E', color: 'white' }}>Closed</span>;
      default:
        return <span className="badge">{status}</span>;
    }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title"><Headset size={28} style={{ marginRight: '10px' }} /> Help & Support</h1>
      </div>

      <div style={{ display: 'flex', gap: '24px', height: 'calc(100vh - 120px)' }}>
        {/* Ticket List */}
        <div className="glass-panel" style={{ flex: 1, overflowY: 'auto' }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Ticket ID</th>
                <th>Subject</th>
                <th>Category</th>
                <th>Status</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading...</td></tr>
              ) : tickets.length === 0 ? (
                <tr><td colSpan="5" style={{ textAlign: 'center' }}>No tickets found</td></tr>
              ) : tickets.map((t) => (
                <tr
                  key={t._id}
                  onClick={() => fetchTicketDetails(t._id)}
                  style={{ cursor: 'pointer', backgroundColor: selectedTicket?._id === t._id ? 'rgba(255,255,255,0.05)' : 'transparent' }}
                >
                  <td style={{ fontWeight: 'bold' }}>{t.ticketId}</td>
                  <td>{t.subject}</td>
                  <td style={{ textTransform: 'capitalize' }}>{t.category.replace('_', ' ')}</td>
                  <td>{getStatusBadge(t.status)}</td>
                  <td>{new Date(t.createdAt).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Ticket Detail Panel */}
        {selectedTicket && (
          <div className="glass-panel" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
            <div style={{ padding: '20px', borderBottom: '1px solid rgba(255,255,255,0.1)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <h2 style={{ margin: '0 0 8px 0', fontSize: '20px' }}>{selectedTicket.subject}</h2>
                  <div style={{ fontSize: '13px', color: 'var(--text-secondary)' }}>
                    Ticket: {selectedTicket.ticketId} • User ID: {selectedTicket.userId}
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <select
                    value={selectedTicket.status}
                    onChange={(e) => handleStatusChange(selectedTicket._id, e.target.value)}
                    style={{
                      padding: '6px 12px',
                      borderRadius: '8px',
                      backgroundColor: 'rgba(255,255,255,0.1)',
                      color: 'white',
                      border: 'none',
                      outline: 'none'
                    }}
                  >
                    <option value="open">Open</option>
                    <option value="in_progress">In Progress</option>
                    <option value="resolved">Resolved</option>
                    <option value="closed">Closed</option>
                  </select>
                </div>
              </div>
            </div>

            <div style={{ flex: 1, overflowY: 'auto', padding: '20px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {selectedTicket.replies?.map((reply, index) => (
                <div key={index} style={{
                  alignSelf: reply.authorRole === 'admin' ? 'flex-end' : 'flex-start',
                  backgroundColor: reply.authorRole === 'admin' ? 'rgba(76, 175, 80, 0.2)' : 'rgba(255,255,255,0.1)',
                  padding: '12px 16px',
                  borderRadius: '12px',
                  maxWidth: '80%'
                }}>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginBottom: '4px', display: 'flex', justifyContent: 'space-between', gap: '12px' }}>
                    <span style={{ fontWeight: 'bold' }}>{reply.authorRole === 'admin' ? 'Support Agent' : 'User'}</span>
                    <span>{new Date(reply.createdAt).toLocaleString()}</span>
                  </div>
                  <div style={{ fontSize: '14px', lineHeight: '1.5' }}>
                    {reply.message}
                  </div>
                </div>
              ))}
            </div>

            <div style={{ padding: '20px', borderTop: '1px solid rgba(255,255,255,0.1)', display: 'flex', gap: '12px' }}>
              <input
                type="text"
                placeholder="Type a reply..."
                value={replyMessage}
                onChange={(e) => setReplyMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleReply()}
                style={{
                  flex: 1,
                  padding: '12px',
                  borderRadius: '8px',
                  backgroundColor: 'rgba(0,0,0,0.2)',
                  border: '1px solid rgba(255,255,255,0.1)',
                  color: 'white',
                  outline: 'none'
                }}
              />
              <button
                className="glass-button primary"
                onClick={handleReply}
                disabled={isSubmitting || !replyMessage.trim()}
                style={{ padding: '0 20px' }}
              >
                <Send size={18} />
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Support;
