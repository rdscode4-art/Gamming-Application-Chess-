import { Routes, Route } from 'react-router-dom'
import Sidebar from './components/Sidebar'
import Dashboard from './pages/Dashboard'
import GameModes from './pages/GameModes'
import Banners from './pages/Banners'
import Tournaments from './pages/Tournaments'
import Users from './pages/Users'
import Settings from './pages/Settings'
import Support from './pages/Support'

function App() {
  return (
    <div className="admin-layout">
      <Sidebar />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/gamemodes" element={<GameModes />} />
          <Route path="/banners" element={<Banners />} />
          <Route path="/tournaments" element={<Tournaments />} />
          <Route path="/users" element={<Users />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/support" element={<Support />} />
        </Routes>
      </main>
    </div>
  )
}

export default App
