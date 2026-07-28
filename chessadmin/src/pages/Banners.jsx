import { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Edit2, Trash2 } from 'lucide-react';

const API_URL = '/api/admin/banners';

const Banners = () => {
  const [banners, setBanners] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    title: '', subtitle: '', cta: '', color: '#fbbf24', icon: 'emoji_events', isActive: true, order: 0
  });

  useEffect(() => {
    fetchBanners();
  }, []);

  const fetchBanners = async () => {
    try {
      const { data } = await axios.get(API_URL);
      setBanners(data);
    } catch (error) {
      console.error('Failed to fetch banners', error);
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
      fetchBanners();
    } catch (error) {
      console.error('Failed to save banner', error);
    }
  };

  const handleDelete = async (id) => {
    if (confirm('Are you sure you want to delete this banner?')) {
      await axios.delete(`${API_URL}/${id}`);
      fetchBanners();
    }
  };

  const openModal = (banner = null) => {
    if (banner) {
      setFormData(banner);
    } else {
      setFormData({
        title: '', subtitle: '', cta: '', color: '#fbbf24', icon: 'emoji_events', isActive: true, order: 0
      });
    }
    setIsModalOpen(true);
  };

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Banners</h1>
        <button className="glass-button primary" onClick={() => openModal()}>
          <Plus size={18} /> Add Banner
        </button>
      </div>

      <div className="glass-panel" style={{ overflow: 'hidden' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Subtitle</th>
              <th>CTA</th>
              <th>Color</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="6" style={{ textAlign: 'center' }}>Loading...</td></tr>
            ) : banners.map((banner) => (
              <tr key={banner._id}>
                <td style={{ fontWeight: 'bold' }}>{banner.title}</td>
                <td>{banner.subtitle}</td>
                <td><span className="badge neutral">{banner.cta}</span></td>
                <td>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ width: '16px', height: '16px', borderRadius: '4px', background: banner.color }}></div>
                    {banner.color}
                  </div>
                </td>
                <td>
                  <span className={`badge ${banner.isActive ? 'active' : 'inactive'}`}>
                    {banner.isActive ? 'Active' : 'Hidden'}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="glass-button" onClick={() => openModal(banner)}><Edit2 size={16} /></button>
                    <button className="glass-button" onClick={() => handleDelete(banner._id)}><Trash2 size={16} color="var(--accent-red)" /></button>
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
              <h2 className="modal-title">{formData._id ? 'Edit Banner' : 'New Banner'}</h2>
            </div>

            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Title (Main Heading)</label>
                <input className="glass-input" value={formData.title} onChange={e => setFormData({ ...formData, title: e.target.value })} required />
              </div>
              <div className="form-group">
                <label className="form-label">Subtitle (Subtext)</label>
                <input className="glass-input" value={formData.subtitle} onChange={e => setFormData({ ...formData, subtitle: e.target.value })} required />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div className="form-group">
                  <label className="form-label">Button CTA Text</label>
                  <input className="glass-input" value={formData.cta} onChange={e => setFormData({ ...formData, cta: e.target.value })} required />
                </div>
                <div className="form-group">
                  <label className="form-label">Background Hex Color</label>
                  <input className="glass-input" value={formData.color} onChange={e => setFormData({ ...formData, color: e.target.value })} required />
                </div>
              </div>

              <div style={{ display: 'flex', gap: '24px', marginTop: '16px' }}>
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input type="checkbox" checked={formData.isActive} onChange={e => setFormData({ ...formData, isActive: e.target.checked })} />
                  Is Active
                </label>
              </div>

              <div className="form-actions">
                <button type="button" className="glass-button" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="glass-button primary">Save Banner</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Banners;
