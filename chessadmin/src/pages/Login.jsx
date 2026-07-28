import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { Lock, Mail, Loader } from 'lucide-react';
import '../index.css';

const API_URL = import.meta.env.VITE_API_URL || 'https://chessback.ridealdigitalseva.com/api';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await axios.post(`${API_URL}/auth/admin-login`, {
        email,
        password
      });

      if (response.data.status === 'success') {
        const { token, admin } = response.data.data;
        login(admin, token);
        navigate('/');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to login. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <div style={styles.header}>
          <div style={styles.logoContainer}>
            <span style={styles.logoText}>♚</span>
          </div>
          <h2 style={styles.title}>Admin Portal</h2>
          <p style={styles.subtitle}>Sign in to manage the platform</p>
        </div>

        {error && <div style={styles.errorBanner}>{error}</div>}

        <form onSubmit={handleLogin} style={styles.form}>
          <div style={styles.inputGroup}>
            <label style={styles.label}>Email Address</label>
            <div style={styles.inputWrapper}>
              <Mail style={styles.inputIcon} size={20} />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                style={styles.input}
                placeholder="admin@example.com"
                required
              />
            </div>
          </div>

          <div style={styles.inputGroup}>
            <label style={styles.label}>Password</label>
            <div style={styles.inputWrapper}>
              <Lock style={styles.inputIcon} size={20} />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                style={styles.input}
                placeholder="••••••••"
                required
              />
            </div>
          </div>

          <button type="submit" style={styles.submitBtn} disabled={loading}>
            {loading ? <Loader size={20} className="spinner" style={styles.spinner} /> : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '100vh',
    width: '100%',
    backgroundColor: '#070D18', // navyDeep
    backgroundImage: 'radial-gradient(circle at 50% 0%, rgba(108, 63, 197, 0.15) 0%, transparent 70%)'
  },
  card: {
    width: '100%',
    maxWidth: '400px',
    padding: '40px 32px',
    backgroundColor: '#0B1220', // navy
    borderRadius: '24px',
    border: '1px solid rgba(255, 255, 255, 0.05)',
    boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)'
  },
  header: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    marginBottom: '32px'
  },
  logoContainer: {
    width: '64px',
    height: '64px',
    borderRadius: '16px',
    background: 'linear-gradient(135deg, #F5A623 0%, #FFCF5C 100%)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: '16px',
    boxShadow: '0 10px 20px -5px rgba(245, 166, 35, 0.3)'
  },
  logoText: {
    fontSize: '32px',
    color: '#070D18' // navyDeep
  },
  title: {
    fontSize: '24px',
    fontWeight: '700',
    color: '#E8EDF8',
    margin: '0 0 8px 0'
  },
  subtitle: {
    fontSize: '14px',
    color: '#8A94A6',
    margin: 0
  },
  errorBanner: {
    backgroundColor: 'rgba(229, 57, 53, 0.1)',
    color: '#E53935',
    padding: '12px 16px',
    borderRadius: '12px',
    fontSize: '14px',
    marginBottom: '24px',
    border: '1px solid rgba(229, 57, 53, 0.2)'
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '20px'
  },
  inputGroup: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  label: {
    fontSize: '14px',
    fontWeight: '500',
    color: '#E8EDF8'
  },
  inputWrapper: {
    position: 'relative',
    display: 'flex',
    alignItems: 'center'
  },
  inputIcon: {
    position: 'absolute',
    left: '16px',
    color: '#8A94A6'
  },
  input: {
    width: '100%',
    padding: '12px 16px 12px 48px',
    backgroundColor: '#070D18',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '12px',
    color: '#E8EDF8',
    fontSize: '15px',
    outline: 'none',
    transition: 'border-color 0.2s'
  },
  submitBtn: {
    width: '100%',
    padding: '14px',
    marginTop: '12px',
    backgroundColor: '#3D2B7A',
    color: 'white',
    border: 'none',
    borderRadius: '12px',
    fontSize: '16px',
    fontWeight: '600',
    cursor: 'pointer',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    transition: 'background-color 0.2s'
  },
  spinner: {
    animation: 'spin 1s linear infinite'
  }
};

export default Login;
