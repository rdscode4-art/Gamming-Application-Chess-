import { useState, useEffect } from 'react';
import axios from 'axios';
import { Send, Bell } from 'lucide-react';

const API_URL = 'https://chessback.ridealdigitalseva.com/api/admin/notifications/send';
const USERS_API_URL = 'https://chessback.ridealdigitalseva.com/api/admin/users';

const Notifications = () => {
  const [users, setUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    body: '',
    targetUserId: 'ALL',
  });

  useEffect(() => {
    // Fetch users to populate the dropdown
    const fetchUsers = async () => {
      try {
        const { data } = await axios.get(USERS_API_URL);
        setUsers(data);
      } catch (error) {
        console.error('Failed to fetch users', error);
      }
    };
    fetchUsers();
  }, []);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSendNotification = async (e) => {
    e.preventDefault();
    if (!formData.title || !formData.body) return alert("Title and Body are required!");
    
    setIsLoading(true);
    try {
      const response = await axios.post(API_URL, formData, {
        withCredentials: true // Ensure admin cookie/token is passed if auth is needed
      });
      alert(response.data.message || 'Notification Sent!');
      setFormData({ title: '', body: '', targetUserId: 'ALL' });
    } catch (error) {
      console.error('Send error:', error);
      alert('Failed to send notification: ' + (error.response?.data?.message || error.message));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Send Notifications</h1>
      </div>

      <div className="glass-panel" style={{ maxWidth: '600px', padding: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '24px' }}>
          <Bell size={24} color="var(--primary-gold)" />
          <h2 style={{ fontSize: '20px', fontWeight: 'bold' }}>Compose Push Notification</h2>
        </div>

        <form onSubmit={handleSendNotification} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          
          <div>
            <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)' }}>Target Audience</label>
            <select
              name="targetUserId"
              value={formData.targetUserId}
              onChange={handleChange}
              style={{
                width: '100%',
                padding: '12px',
                background: 'rgba(255, 255, 255, 0.05)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                color: 'var(--text-light)',
                outline: 'none'
              }}
            >
              <option value="ALL">All Users (Broadcast)</option>
              {users.map(u => (
                <option key={u._id} value={u._id}>{u.username} ({u.phoneNumber || u.email})</option>
              ))}
            </select>
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)' }}>Notification Title</label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleChange}
              placeholder="e.g., Weekend Tournament is Live!"
              required
              style={{
                width: '100%',
                padding: '12px',
                background: 'rgba(255, 255, 255, 0.05)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                color: 'var(--text-light)',
                outline: 'none'
              }}
            />
          </div>

          <div>
            <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)' }}>Notification Body</label>
            <textarea
              name="body"
              value={formData.body}
              onChange={handleChange}
              placeholder="Write the message here..."
              required
              rows="4"
              style={{
                width: '100%',
                padding: '12px',
                background: 'rgba(255, 255, 255, 0.05)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                color: 'var(--text-light)',
                outline: 'none',
                resize: 'vertical'
              }}
            ></textarea>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="glass-button primary"
            style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginTop: '16px' }}
          >
            {isLoading ? 'Sending...' : (
              <>
                <Send size={18} />
                Send Notification
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Notifications;
