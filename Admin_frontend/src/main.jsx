import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
const style = document.createElement("style");
style.innerHTML = `
@keyframes load {
  from { width: 0%; }
  to { width: 100%; }
}`;
document.head.appendChild(style);