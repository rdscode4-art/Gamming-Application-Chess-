import { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { Plus, Trash2, Edit, Save, X, Image as ImageIcon, Video, Play, FileText } from 'lucide-react';

const API_URL = '/api/admin/guides';

const Guides = () => {
  const { token } = useAuth();
  const [guides, setGuides] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({
    _id: '',
    title: '',
    content: '',
    mediaType: 'none',
    mediaUrl: '',
    order: 0
  });
  const [selectedFile, setSelectedFile] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchGuides();
  }, []);

  const fetchGuides = async () => {
    try {
      const { data } = await axios.get('/api/guides'); // Public endpoint
      if (data.status === 'success') {
        setGuides(data.data);
      }
    } catch (error) {
      console.error('Failed to fetch guides', error);
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (guide) => {
    setFormData(guide);
    setSelectedFile(null);
    setShowForm(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this guide section?')) return;
    try {
      await axios.delete(`${API_URL}/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      fetchGuides();
    } catch (error) {
      console.error('Failed to delete guide', error);
      alert('Failed to delete guide');
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const data = new FormData();
      data.append('title', formData.title);
      data.append('content', formData.content);
      data.append('mediaType', formData.mediaType);
      data.append('order', formData.order);
      
      // If youtube or URL, pass mediaUrl directly
      if (formData.mediaType === 'youtube' || (formData.mediaType !== 'none' && !selectedFile)) {
        data.append('mediaUrl', formData.mediaUrl);
      }

      if (selectedFile && (formData.mediaType === 'image' || formData.mediaType === 'video')) {
        data.append('media', selectedFile);
      }

      const config = {
        headers: { 
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data'
        }
      };

      if (formData._id) {
        await axios.put(`${API_URL}/${formData._id}`, data, config);
      } else {
        await axios.post(API_URL, data, config);
      }
      
      setShowForm(false);
      fetchGuides();
    } catch (error) {
      console.error('Failed to save guide', error);
      alert('Failed to save guide');
    } finally {
      setSubmitting(false);
    }
  };

  const resetForm = () => {
    setFormData({ _id: '', title: '', content: '', mediaType: 'none', mediaUrl: '', order: 0 });
    setSelectedFile(null);
    setShowForm(true);
  };

  const getMediaIcon = (type) => {
    switch (type) {
      case 'image': return <ImageIcon size={18} color="#3B82F6" />;
      case 'video': return <Video size={18} color="#F5A623" />;
      case 'youtube': return <Play size={18} color="#E53935" />;
      default: return <FileText size={18} color="#8A94A6" />;
    }
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1 className="page-title">Chess Guide</h1>
          <p className="page-subtitle">Manage tutorial sections and media</p>
        </div>
        <button className="primary-btn" onClick={resetForm} style={{ display: showForm ? 'none' : 'flex' }}>
          <Plus size={20} /> Add Section
        </button>
      </div>

      {showForm && (
        <div className="modal-overlay" onClick={() => setShowForm(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h2 className="modal-title">{formData._id ? 'Edit Section' : 'New Section'}</h2>
              <button type="button" className="icon-btn" onClick={() => setShowForm(false)}><X size={20} /></button>
            </div>

          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div className="form-group">
              <label className="form-label">Title</label>
              <input
                type="text"
                className="form-input"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                required
                placeholder="e.g. Basic Piece Movements"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Content (Text)</label>
              <textarea
                className="form-input"
                value={formData.content}
                onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                required
                rows={6}
                placeholder="Write the guide content here..."
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div className="form-group">
                <label className="form-label">Media Type</label>
                <select
                  className="form-input"
                  value={formData.mediaType}
                  onChange={(e) => setFormData({ ...formData, mediaType: e.target.value, mediaUrl: '' })}
                >
                  <option value="none">Text Only</option>
                  <option value="image">Image Upload</option>
                  <option value="video">Video Upload</option>
                  <option value="youtube">YouTube Link</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Order (Sorting)</label>
                <input
                  type="number"
                  className="form-input"
                  value={formData.order}
                  onChange={(e) => setFormData({ ...formData, order: parseInt(e.target.value) })}
                />
              </div>
            </div>

            {formData.mediaType === 'youtube' && (
              <div className="form-group">
                <label className="form-label">YouTube URL</label>
                <input
                  type="url"
                  className="form-input"
                  value={formData.mediaUrl}
                  onChange={(e) => setFormData({ ...formData, mediaUrl: e.target.value })}
                  placeholder="https://www.youtube.com/watch?v=..."
                  required
                />
              </div>
            )}

            {(formData.mediaType === 'image' || formData.mediaType === 'video') && (
              <div className="form-group">
                <label className="form-label">Upload File {formData._id && '(Leave empty to keep existing)'}</label>
                <input
                  type="file"
                  accept={formData.mediaType === 'image' ? 'image/*' : 'video/*'}
                  onChange={(e) => setSelectedFile(e.target.files[0])}
                  style={{ color: 'white' }}
                />
                {formData.mediaUrl && !selectedFile && (
                  <p style={{ color: '#8A94A6', fontSize: '12px', marginTop: '8px' }}>
                    Current file: {formData.mediaUrl}
                  </p>
                )}
              </div>
            )}

            <div className="form-actions">
              <button type="button" className="glass-button" onClick={() => setShowForm(false)}>
                Cancel
              </button>
              <button type="submit" className="glass-button primary" disabled={submitting}>
                <Save size={18} /> {submitting ? 'Saving...' : 'Save Section'}
              </button>
            </div>
          </form>
        </div>
      </div>
      )}

      <div className="glass-panel" style={{ overflowX: 'auto' }}>
        <table className="data-table">
          <thead>
            <tr>
              <th>Order</th>
              <th>Title</th>
              <th>Media</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="4" style={{ textAlign: 'center', padding: '24px' }}>Loading...</td></tr>
            ) : guides.length === 0 ? (
              <tr><td colSpan="4" style={{ textAlign: 'center', padding: '24px' }}>No guide sections found. Click "Add Section".</td></tr>
            ) : (
              guides.map((guide) => (
                <tr key={guide._id}>
                  <td><span className="badge" style={{ background: 'rgba(255,255,255,0.1)' }}>{guide.order}</span></td>
                  <td>
                    <strong>{guide.title}</strong>
                    <p style={{ color: '#8A94A6', fontSize: '12px', marginTop: '4px', overflow: 'hidden', textOverflow: 'ellipsis', display: '-webkit-box', WebkitLineClamp: 1, WebkitBoxOrient: 'vertical' }}>
                      {guide.content}
                    </p>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#8A94A6', fontSize: '14px', textTransform: 'capitalize' }}>
                      {getMediaIcon(guide.mediaType)}
                      {guide.mediaType}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button className="icon-btn" onClick={() => handleEdit(guide)}><Edit size={18} /></button>
                      <button className="icon-btn delete" onClick={() => handleDelete(guide._id)}><Trash2 size={18} /></button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Guides;
