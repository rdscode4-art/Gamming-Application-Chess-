import { useState, useEffect } from 'react';
import axios from 'axios';
import { Save } from 'lucide-react';

const API_URL = '/api/settings';
const ADMIN_TOKEN = localStorage.getItem('adminToken') || '';

function Settings() {
  const [commission, setCommission] = useState(10);
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const { data } = await axios.get(API_URL, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      const settings = data.settings || [];
      const commSetting = settings.find(s => s.key === 'user_private_tournament_commission');
      if (commSetting) {
        setCommission(Number(commSetting.value));
      }
    } catch (error) {
      console.error('Failed to fetch settings', error);
    }
  };

  const handleSave = async () => {
    setIsLoading(true);
    setMessage('');
    try {
      await axios.put(`${API_URL}/user_private_tournament_commission`, {
        value: commission,
        description: 'Commission percentage taken by the platform for user-created private tournaments.'
      }, {
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` }
      });
      setMessage('Settings saved successfully!');
      setTimeout(() => setMessage(''), 3000);
    } catch (error) {
      console.error('Failed to save settings', error);
      setMessage('Error saving settings.');
    }
    setIsLoading(false);
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Platform Settings</h1>
      </div>

      <div className="glass-panel" style={{ padding: '24px', maxWidth: '600px' }}>
        <h3>Private Tournaments</h3>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginBottom: '20px' }}>
          Manage the platform commission for private tournaments created by users from the mobile app.
        </p>

        <div style={{ marginBottom: '24px' }}>
          <label style={{ display: 'block', marginBottom: '8px', fontWeight: 'bold' }}>
            Commission Percentage (%)
          </label>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <input
              type="range"
              min="0"
              max="50"
              value={commission}
              onChange={(e) => setCommission(Number(e.target.value))}
              style={{ flex: 1 }}
            />
            <span style={{
              fontWeight: 'bold',
              fontSize: '18px',
              minWidth: '40px',
              color: 'var(--accent-gold)'
            }}>
              {commission}%
            </span>
          </div>
        </div>

        <button
          className="glass-button primary"
          onClick={handleSave}
          disabled={isLoading}
        >
          <Save size={18} /> {isLoading ? 'Saving...' : 'Save Settings'}
        </button>

        {message && (
          <div style={{
            marginTop: '16px',
            padding: '12px',
            borderRadius: '8px',
            backgroundColor: message.includes('Error') ? 'rgba(255, 82, 82, 0.1)' : 'rgba(76, 175, 80, 0.1)',
            color: message.includes('Error') ? '#FF5252' : '#4CAF50'
          }}>
            {message}
          </div>
        )}
      </div>
    </div>
  );
}

export default Settings;
