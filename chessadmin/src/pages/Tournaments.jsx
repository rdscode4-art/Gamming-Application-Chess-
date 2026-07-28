import { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Edit2, Trash2 } from 'lucide-react';

const API_URL = '/api/admin/tournaments';

const Tournaments = () => {
  const [tournaments, setTournaments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Format dates for input type="datetime-local"
  const formatDateForInput = (dateStr) => {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
  };

  const [formData, setFormData] = useState({
    name: '', format: 'knockout', timeControl: 'rapid_10', maxPlayers: 8, entryFee: 0, prizePool: 0, status: 'registration', startTime: ''
  });

  useEffect(() => {
    fetchTournaments();
  }, []);

  const fetchTournaments = async () => {
    try {
      const { data } = await axios.get(API_URL);
      setTournaments(data);
    } catch (error) {
      console.error('Failed to fetch tournaments', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const submitData = { ...formData, startTime: new Date(formData.startTime).toISOString() };

      if (formData._id) {
        await axios.put(`${API_URL}/${formData._id}`, submitData);
      } else {
        await axios.post(API_URL, submitData);
      }
      setIsModalOpen(false);
      fetchTournaments();
    } catch (error) {
      console.error('Failed to save tournament', error);
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Are you sure you want to delete this tournament?')) {
      await axios.delete(`${API_URL}/${id}`);
      fetchTournaments();
    }
  };

  const openModal = (t = null) => {
    if (t) {
      setFormData({ ...t, startTime: formatDateForInput(t.startTime), commissionPercentage: t.commissionPercentage || 10, customDistribution: (t.prizeDistribution && t.prizeDistribution.length > 0) ? t.prizeDistribution.map(p => p.percentage) : [100] });
    } else {
      setFormData({
        name: '', format: 'knockout', timeControl: 'rapid_10', maxPlayers: 8, entryFee: 0, status: 'registration', startTime: formatDateForInput(new Date()), commissionPercentage: 10, customDistribution: [100]
      });
    }
    setIsModalOpen(true);
  };

  const handleWinnersChange = (num) => {
    if (num === 1) {
      setFormData({ ...formData, customDistribution: [100] });
      return;
    }
    if (num === 2) {
      setFormData({ ...formData, customDistribution: [70, 30] });
      return;
    }
    if (num === 3) {
      setFormData({ ...formData, customDistribution: [50, 30, 20] });
      return;
    }

    let weights = [];
    let totalWeight = 0;
    for (let i = 1; i <= num; i++) {
      let w = num - i + 1; // Linear decrease
      weights.push(w);
      totalWeight += w;
    }

    let dist = weights.map(w => {
      let exact = (w / totalWeight) * 100;
      return { floor: Math.floor(exact), remainder: exact - Math.floor(exact) };
    });

    let sum = dist.reduce((a, b) => a + b.floor, 0);
    let needed = 100 - sum;

    // Sort indices by largest remainder
    let indices = dist.map((_, i) => i).sort((a, b) => dist[b].remainder - dist[a].remainder);

    for (let i = 0; i < needed; i++) {
      dist[indices[i]].floor += 1;
    }

    setFormData({ ...formData, customDistribution: dist.map(d => d.floor) });
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Tournaments</h1>
        <button className="glass-button primary" onClick={() => openModal()}>
          <Plus size={18} /> Schedule Tournament
        </button>
      </div>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Format</th>
              <th>Entry / Prize</th>
              <th>Start Time</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="6" style={{ textAlign: 'center' }}>Loading...</td></tr>
            ) : tournaments.map((t) => (
              <tr key={t._id}>
                <td style={{ fontWeight: 'bold' }}>{t.name}</td>
                <td>{t.format.toUpperCase()} ({t.maxPlayers}P)</td>
                <td>
                  <span style={{ color: 'var(--accent-red)' }}>₹{t.entryFee}</span> /{' '}
                  <span style={{ color: 'var(--accent-green)' }}>₹{t.prizePool}</span>
                </td>
                <td>{new Date(t.startTime).toLocaleString()}</td>
                <td>
                  <span className={`badge ${t.status === 'registration' ? 'active' : 'neutral'}`}>
                    {t.status.toUpperCase()}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="glass-button" onClick={() => openModal(t)}><Edit2 size={16} /></button>
                    <button className="glass-button" onClick={() => handleDelete(t._id)}><Trash2 size={16} color="var(--accent-red)" /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isModalOpen && (
        <div className="modal-overlay" onClick={() => setIsModalOpen(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxHeight: '90vh', overflowY: 'auto' }}>
            <div className="modal-header">
              <h2 className="modal-title">{formData._id ? 'Edit Tournament' : 'New Tournament'}</h2>
            </div>

            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Tournament Name</label>
                <input className="glass-input" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} required />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">Format</label>
                  <select className="glass-input" value={formData.format} onChange={e => setFormData({ ...formData, format: e.target.value })}>
                    <option value="knockout">Knockout</option>
                    <option value="swiss">Swiss</option>
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Time Control</label>
                  <select className="glass-input" value={formData.timeControl} onChange={e => setFormData({ ...formData, timeControl: e.target.value })}>
                    <option value="rapid_3">Bullet 3+0</option>
                    <option value="rapid_5">Blitz 5+0</option>
                    <option value="rapid_10">Rapid 10+0</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Max Players</label>
                  <select className="glass-input" value={formData.maxPlayers} onChange={e => setFormData({ ...formData, maxPlayers: Number(e.target.value) })}>
                    <option value="2">2 Players</option>
                    <option value="4">4 Players</option>
                    <option value="8">8 Players</option>
                    <option value="16">16 Players</option>
                    <option value="32">32 Players</option>
                    <option value="64">64 Players</option>
                    <option value="128">128 Players</option>
                    <option value="256">256 Players</option>
                  </select>
                </div>
                <div className="form-group">
                  <label className="form-label">Status</label>
                  <select className="glass-input" value={formData.status} onChange={e => setFormData({ ...formData, status: e.target.value })}>
                    <option value="draft">Draft</option>
                    <option value="registration">Registration</option>
                    <option value="ongoing">Ongoing</option>
                    <option value="completed">Completed</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Entry Fee (₹)</label>
                  <input type="number" className="glass-input" value={formData.entryFee} onChange={e => setFormData({ ...formData, entryFee: Number(e.target.value) })} />
                </div>
                <div className="form-group">
                  <label className="form-label">Commission (%)</label>
                  <input type="number" className="glass-input" value={formData.commissionPercentage} onChange={e => setFormData({ ...formData, commissionPercentage: Number(e.target.value) })} />
                </div>
                <div className="form-group">
                  <label className="form-label">Prize Pool (₹) - Auto Calculated</label>
                  <input type="number" className="glass-input" value={Math.floor((formData.entryFee || 0) * (formData.maxPlayers || 8) * (1 - (formData.commissionPercentage || 10) / 100))} readOnly style={{ backgroundColor: 'rgba(0,0,0,0.2)', color: 'var(--text-secondary)' }} />
                </div>

                <div className="form-group" style={{ gridColumn: '1 / -1' }}>
                  <label className="form-label">Number of Winners: {(formData.customDistribution || []).length}</label>
                  <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                    <input
                      type="range"
                      min="1"
                      max={formData.maxPlayers || 8}
                      value={(formData.customDistribution || []).length}
                      onChange={e => handleWinnersChange(Number(e.target.value))}
                      style={{ flex: 1, cursor: 'pointer' }}
                    />
                  </div>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', padding: '16px', backgroundColor: 'rgba(0,0,0,0.2)', borderRadius: '8px', marginTop: '16px' }}>
                    {(formData.customDistribution || []).map((pct, idx) => (
                      <div key={idx} style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <span style={{ width: '60px', fontWeight: 'bold' }}>Rank {idx + 1}</span>
                        <input
                          type="number"
                          min="0" max="100"
                          className="glass-input"
                          style={{ width: '100px', padding: '8px' }}
                          value={pct}
                          onChange={e => {
                            let newDist = [...formData.customDistribution];
                            newDist[idx] = Number(e.target.value);
                            setFormData({ ...formData, customDistribution: newDist });
                          }}
                        />
                        <span style={{ color: 'var(--text-secondary)' }}>%</span>
                        <span style={{ color: 'var(--accent-green)', marginLeft: 'auto', fontWeight: 'bold' }}>
                          ₹ {Math.floor(((formData.entryFee || 0) * (formData.maxPlayers || 8) * (1 - (formData.commissionPercentage || 10) / 100)) * (pct / 100))}
                        </span>
                      </div>
                    ))}

                    <div style={{ marginTop: '12px', borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '12px', display: 'flex', justifyContent: 'space-between', fontWeight: 'bold' }}>
                      <span>Total Distribution</span>
                      <span style={{ color: (formData.customDistribution || []).reduce((a, b) => a + b, 0) === 100 ? 'var(--accent-green)' : 'var(--accent-red)' }}>
                        {(formData.customDistribution || []).reduce((a, b) => a + b, 0)}%
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="form-group" style={{ marginTop: '16px' }}>
                <label className="form-label">Start Time</label>
                <input type="datetime-local" className="glass-input" value={formData.startTime} onChange={e => setFormData({ ...formData, startTime: e.target.value })} required />
              </div>

              <div className="form-actions">
                <button type="button" className="glass-button" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="glass-button primary" disabled={(formData.customDistribution || []).reduce((a, b) => a + b, 0) !== 100}>Save Tournament</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Tournaments;
