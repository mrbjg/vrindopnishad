import React, { useState, useEffect, useContext } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { API, AuthContext } from '../App';
import Navigation from '../components/Navigation';
import { Plus, X, Edit2, Trash2, Music, Image as ImageIcon, Video, Sparkles, Save } from 'lucide-react';

const AdminDashboard = () => {
  const { token } = useContext(AuthContext);
  const [content, setContent] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [editingId, setEditingId] = useState(null);

  // Form state
  const [formData, setFormData] = useState({
    title: '',
    sanskrit_text: '',
    hindi_text: '',
    english_text: '',
    english_translation: '',
    category: 'shloka',
    description: ''
  });

  // AI generation states
  const [audioGenText, setAudioGenText] = useState('');
  const [audioGenLang, setAudioGenLang] = useState('hi-IN');
  const [imagePrompt, setImagePrompt] = useState('');
  const [generatingAudio, setGeneratingAudio] = useState(false);
  const [generatingImage, setGeneratingImage] = useState(false);
  const [selectedContentId, setSelectedContentId] = useState(null);

  useEffect(() => {
    fetchContent();
  }, []);

  const fetchContent = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API}/content`);
      setContent(response.data.content || []);
    } catch (error) {
      console.error('Error fetching content:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const headers = { Authorization: `Bearer ${token}` };
      
      if (editingId) {
        await axios.put(`${API}/content/${editingId}`, formData, { headers });
        alert('Content updated successfully!');
      } else {
        await axios.post(`${API}/content`, formData, { headers });
        alert('Content created successfully!');
      }

      resetForm();
      fetchContent();
    } catch (error) {
      alert('Error saving content: ' + (error.response?.data?.detail || error.message));
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this content?')) return;

    try {
      const headers = { Authorization: `Bearer ${token}` };
      await axios.delete(`${API}/content/${id}`, { headers });
      alert('Content deleted successfully!');
      fetchContent();
    } catch (error) {
      alert('Error deleting content: ' + (error.response?.data?.detail || error.message));
    }
  };

  const handleEdit = (item) => {
    setFormData({
      title: item.title || '',
      sanskrit_text: item.sanskrit_text || '',
      hindi_text: item.hindi_text || '',
      english_text: item.english_text || '',
      english_translation: item.english_translation || '',
      category: item.category || 'shloka',
      description: item.description || ''
    });
    setEditingId(item.id);
    setShowCreateForm(true);
  };

  const resetForm = () => {
    setFormData({
      title: '',
      sanskrit_text: '',
      hindi_text: '',
      english_text: '',
      english_translation: '',
      category: 'shloka',
      description: ''
    });
    setEditingId(null);
    setShowCreateForm(false);
  };

  const handleGenerateAudio = async () => {
    if (!selectedContentId || !audioGenText) {
      alert('Please select content and enter text for audio generation');
      return;
    }

    try {
      setGeneratingAudio(true);
      const headers = { Authorization: `Bearer ${token}` };
      const response = await axios.post(
        `${API}/content/${selectedContentId}/generate-audio`,
        { text: audioGenText, language: audioGenLang },
        { headers }
      );
      alert('Audio generated successfully!');
      fetchContent();
      setAudioGenText('');
      setSelectedContentId(null);
    } catch (error) {
      alert('Error generating audio: ' + (error.response?.data?.detail || error.message));
    } finally {
      setGeneratingAudio(false);
    }
  };

  const handleGenerateImage = async () => {
    if (!selectedContentId || !imagePrompt) {
      alert('Please select content and enter an image prompt');
      return;
    }

    try {
      setGeneratingImage(true);
      const headers = { Authorization: `Bearer ${token}` };
      const response = await axios.post(
        `${API}/content/${selectedContentId}/generate-image`,
        { prompt: imagePrompt },
        { headers }
      );
      alert('Image generated successfully!');
      fetchContent();
      setImagePrompt('');
      setSelectedContentId(null);
    } catch (error) {
      alert('Error generating image: ' + (error.response?.data?.detail || error.message));
    } finally {
      setGeneratingImage(false);
    }
  };

  const handleFileUpload = async (contentId, file, type) => {
    try {
      const headers = { Authorization: `Bearer ${token}` };
      const formData = new FormData();
      formData.append('file', file);

      await axios.post(`${API}/upload/${type}/${contentId}`, formData, { headers });
      alert(`${type.charAt(0).toUpperCase() + type.slice(1)} uploaded successfully!`);
      fetchContent();
    } catch (error) {
      alert(`Error uploading ${type}: ` + (error.response?.data?.detail || error.message));
    }
  };

  return (
    <div>
      <Navigation />
      <div className="container mt-4">
        <div className="mb-4" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1 data-testid="admin-dashboard-title">Admin Dashboard</h1>
          <button
            className="btn btn-primary"
            onClick={() => setShowCreateForm(!showCreateForm)}
            data-testid="toggle-create-form-btn"
            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
          >
            {showCreateForm ? (
              <>
                <X size={20} />
                Cancel
              </>
            ) : (
              <>
                <Plus size={20} />
                Create New Content
              </>
            )}
          </button>
        </div>

        {showCreateForm && (
          <div className="card mb-4" style={{ padding: '2rem' }}>
            <h2 className="mb-3">{editingId ? 'Edit Content' : 'Create New Content'}</h2>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label className="form-label">Title *</label>
                <input
                  type="text"
                  className="form-input"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  required
                  data-testid="title-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Category *</label>
                <select
                  className="form-select"
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  data-testid="category-select"
                >
                  <option value="shloka">Shloka</option>
                  <option value="strotra">Strotra</option>
                  <option value="poem">Poem</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label">Description</label>
                <textarea
                  className="form-textarea"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  data-testid="description-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Sanskrit Text</label>
                <textarea
                  className="form-textarea"
                  value={formData.sanskrit_text}
                  onChange={(e) => setFormData({ ...formData, sanskrit_text: e.target.value })}
                  placeholder="Enter Sanskrit text in Devanagari script"
                  data-testid="sanskrit-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Hindi Text</label>
                <textarea
                  className="form-textarea"
                  value={formData.hindi_text}
                  onChange={(e) => setFormData({ ...formData, hindi_text: e.target.value })}
                  placeholder="Enter Hindi text"
                  data-testid="hindi-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">English Transliteration</label>
                <textarea
                  className="form-textarea"
                  value={formData.english_text}
                  onChange={(e) => setFormData({ ...formData, english_text: e.target.value })}
                  placeholder="Enter English transliteration"
                  data-testid="english-input"
                />
              </div>

              <div className="form-group">
                <label className="form-label">English Translation</label>
                <textarea
                  className="form-textarea"
                  value={formData.english_translation}
                  onChange={(e) => setFormData({ ...formData, english_translation: e.target.value })}
                  placeholder="Enter English translation"
                  data-testid="translation-input"
                />
              </div>

              <div style={{ display: 'flex', gap: '1rem' }}>
                <button type="submit" className="btn btn-primary" data-testid="submit-btn" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <Save size={20} />
                  {editingId ? 'Update Content' : 'Create Content'}
                </button>
                {editingId && (
                  <button type="button" className="btn btn-outline" onClick={resetForm} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <X size={20} />
                    Cancel Edit
                  </button>
                )}
              </div>
            </form>
          </div>
        )}

        <div className="card mb-4" style={{ padding: '2rem' }}>
          <h2 className="mb-3">AI Generation Tools</h2>
          
          <div className="mb-4">
            <h3 style={{ fontSize: '1.3rem', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <Music size={24} />
              Generate Audio (Google TTS)
            </h3>
            <div className="form-group">
              <label className="form-label">Select Content</label>
              <select
                className="form-select"
                value={selectedContentId || ''}
                onChange={(e) => setSelectedContentId(e.target.value)}
                data-testid="audio-content-select"
              >
                <option value="">-- Select Content --</option>
                {content.map((item) => (
                  <option key={item.id} value={item.id}>{item.title}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Language</label>
              <select
                className="form-select"
                value={audioGenLang}
                onChange={(e) => setAudioGenLang(e.target.value)}
              >
                <option value="hi-IN">Hindi</option>
                <option value="en-IN">English (Indian)</option>
                <option value="sa-IN">Sanskrit (via Hindi)</option>
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Text for Audio</label>
              <textarea
                className="form-textarea"
                value={audioGenText}
                onChange={(e) => setAudioGenText(e.target.value)}
                placeholder="Enter text to convert to speech"
                data-testid="audio-text-input"
              />
            </div>
            <button
              className="btn btn-secondary"
              onClick={handleGenerateAudio}
              disabled={generatingAudio}
              data-testid="generate-audio-btn"
              style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
            >
              <Sparkles size={20} />
              {generatingAudio ? 'Generating...' : 'Generate Audio'}
            </button>
          </div>

          <div className="decorative-border"></div>

          <div className="mt-4">
            <h3 style={{ fontSize: '1.3rem', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <ImageIcon size={24} />
              Generate Image (Gemini Nano Banana)
            </h3>
            <div className="form-group">
              <label className="form-label">Select Content</label>
              <select
                className="form-select"
                value={selectedContentId || ''}
                onChange={(e) => setSelectedContentId(e.target.value)}
                data-testid="image-content-select"
              >
                <option value="">-- Select Content --</option>
                {content.map((item) => (
                  <option key={item.id} value={item.id}>{item.title}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Image Prompt</label>
              <textarea
                className="form-textarea"
                value={imagePrompt}
                onChange={(e) => setImagePrompt(e.target.value)}
                placeholder="Describe the image you want to generate (e.g., 'Create a divine image of Lord Krishna playing flute in Vrindavan with peacocks and cows')"
                data-testid="image-prompt-input"
              />
            </div>
            <button
              className="btn btn-secondary"
              onClick={handleGenerateImage}
              disabled={generatingImage}
              data-testid="generate-image-btn"
              style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
            >
              <Sparkles size={20} />
              {generatingImage ? 'Generating...' : 'Generate Image'}
            </button>
          </div>
        </div>

        <div className="card">
          <h2 className="mb-3">Content Management</h2>
          {loading ? (
            <div className="text-center">
              <div className="spinner"></div>
            </div>
          ) : content.length === 0 ? (
            <p className="text-center" style={{ color: '#666' }}>No content created yet.</p>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid #ff6b35' }}>
                    <th style={{ padding: '1rem', textAlign: 'left' }}>Title</th>
                    <th style={{ padding: '1rem', textAlign: 'left' }}>Category</th>
                    <th style={{ padding: '1rem', textAlign: 'center' }}>Media</th>
                    <th style={{ padding: '1rem', textAlign: 'center' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {content.map((item) => (
                    <tr key={item.id} style={{ borderBottom: '1px solid #eee' }}>
                      <td style={{ padding: '1rem' }} data-testid={`content-row-${item.id}`}>
                        <Link to={`/content/${item.id}`} style={{ color: '#ff6b35', textDecoration: 'none' }}>
                          {item.title}
                        </Link>
                      </td>
                      <td style={{ padding: '1rem' }}>
                        <span className={`category-badge category-${item.category}`}>{item.category}</span>
                      </td>
                      <td style={{ padding: '1rem', textAlign: 'center' }}>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}>
                          {item.audio_url && (
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                              <Music size={16} />
                            </span>
                          )}
                          {item.image_urls && item.image_urls.length > 0 && (
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                              <ImageIcon size={16} />
                              <span style={{ fontSize: '0.85rem' }}>({item.image_urls.length})</span>
                            </span>
                          )}
                          {item.video_urls && item.video_urls.length > 0 && (
                            <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                              <Video size={16} />
                              <span style={{ fontSize: '0.85rem' }}>({item.video_urls.length})</span>
                            </span>
                          )}
                        </div>
                      </td>
                      <td style={{ padding: '1rem', textAlign: 'center' }}>
                        <button
                          className="btn btn-outline"
                          style={{ padding: '0.5rem 1rem', marginRight: '0.5rem', display: 'inline-flex', alignItems: 'center', gap: '0.5rem' }}
                          onClick={() => handleEdit(item)}
                          data-testid={`edit-btn-${item.id}`}
                        >
                          <Edit2 size={16} />
                          Edit
                        </button>
                        <button
                          className="btn"
                          style={{ padding: '0.5rem 1rem', background: '#dc3545', color: 'white', display: 'inline-flex', alignItems: 'center', gap: '0.5rem' }}
                          onClick={() => handleDelete(item.id)}
                          data-testid={`delete-btn-${item.id}`}
                        >
                          <Trash2 size={16} />
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default AdminDashboard;
