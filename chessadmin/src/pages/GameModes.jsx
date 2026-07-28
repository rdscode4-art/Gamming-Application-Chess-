import { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Edit2, Trash2 } from 'lucide-react';

const API_URL = '/api/admin/gamemodes';

const GameModes = () => {
  const [modes, setModes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    modeId: '', label: '', tag: '', timeControl: 'rapid_10', entryFee: 0, prize: 0, isRated: false, isActive: true, order: 0
  });

  useEffect(() => {
    fetchModes();
  }, []);

  const fetchModes = async () => {
    try {
      const { data } = await axios.get(API_URL);
      setModes(data);
    } catch (error) {
      console.error('Failed to fetch modes', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (formData._id) {
        await axios.put(`${API_URL}/${formData._id}`, formData);
      } else {
        await axios.post(API_URL, formData);
      }
      setIsModalOpen(false);
      fetchModes();
    } catch (error) {
      console.error('Failed to save mode', error);
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Are you sure you want to delete this mode?')) {
      await axios.delete(`${API_URL}/${id}`);
      fetchModes();
    }
  };

  const openModal = (mode = null) => {
    if (mode) {
      setFormData(mode);
    } else {
      setFormData({
        modeId: '', label: '', tag: '', timeControl: 'rapid_10', entryFee: 0, prize: 0, isRated: false, isActive: true, order: 0
      });
    }
    setIsModalOpen(true);
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Game Modes</h1>
        <button className="glass-button primary" onClick={() => openModal()}>
          <Plus size={18} /> Add New Mode
        </button>
      </div>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Label</th>
              <th>Time Control</th>
              <th>Entry / Prize</th>
              <th>Tag</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="6" style={{ textAlign: 'center' }}>Loading...</td></tr>
            ) : modes.map((mode) => (
              <tr key={mode._id}>
                <td style={{ fontWeight: 'bold' }}>{mode.label}</td>
                <td>{mode.timeControl}</td>
                <td>
                  <span style={{ color: 'var(--accent-red)' }}>₹{mode.entryFee}</span> /{' '}
                  <span style={{ color: 'var(--accent-green)' }}>₹{mode.prize}</span>
                </td>
                <td><span className="badge neutral">{mode.tag}</span></td>
                <td>
                  <span className={`badge ${mode.isActive ? 'active' : 'inactive'}`}>
                    {mode.isActive ? 'Active' : 'Hidden'}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="glass-button" onClick={() => openModal(mode)}><Edit2 size={16} /></button>
                    <button className="glass-button" onClick={() => handleDelete(mode._id)}><Trash2 size={16} color="var(--accent-red)" /></button>
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
              <h2 className="modal-title">{formData._id ? 'Edit Mode' : 'New Mode'}</h2>
            </div>

            <form onSubmit={handleSubmit}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">Mode ID (e.g. paid_50)</label>
                  <input className="glass-input" value={formData.modeId} onChange={e => setFormData({ ...formData, modeId: e.target.value })} required />
                </div>
                <div className="form-group">
                  <label className="form-label">Label (e.g. ₹50 Match)</label>
                  <input className="glass-input" value={formData.label} onChange={e => setFormData({ ...formData, label: e.target.value })} required />
                </div>

                <div className="form-group">
                  <label className="form-label">Time Control</label>
                  <select className="glass-input" value={formData.timeControl} onChange={e => setFormData({ ...formData, timeControl: e.target.value })}>
                    <option value="rapid_3">Bullet 3+0</option>
                    <option value="rapid_5">Blitz 5+0</option>
                    <option value="rapid_10">Rapid 10+0</option>
                    <option value="classic_15">Classic 15+0</option>
                    <option value="classic_30">Classic 30+0</option>
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Tag Badge (e.g. ₹50 or Free)</label>
                  <input className="glass-input" value={formData.tag} onChange={e => setFormData({ ...formData, tag: e.target.value })} />
                </div>

                <div className="form-group">
                  <label className="form-label">Entry Fee (₹)</label>
                  <input type="number" className="glass-input" value={formData.entryFee} onChange={e => setFormData({ ...formData, entryFee: Number(e.target.value) })} />
                </div>
                <div className="form-group">
                  <label className="form-label">Prize Pool (₹)</label>
                  <input type="number" className="glass-input" value={formData.prize} onChange={e => setFormData({ ...formData, prize: Number(e.target.value) })} />
                </div>
              </div>

              <div style={{ display: 'flex', gap: '24px', marginTop: '16px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input type="checkbox" checked={formData.isActive} onChange={e => setFormData({ ...formData, isActive: e.target.checked })} />
                  Is Active (Visible in App)
                </label>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input type="checkbox" checked={formData.isRated} onChange={e => setFormData({ ...formData, isRated: e.target.checked })} />
                  Is Rated (Affects ELO)
                </label>
              </div>

              <div className="form-actions">
                <button type="button" className="glass-button" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="glass-button primary">Save Mode</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default GameModes;
