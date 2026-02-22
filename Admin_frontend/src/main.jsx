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
  0% {
    width: 0%;
  }
  60% {
    width: 85%;
  }
  100% {
    width: 100%;
  }
}

@keyframes shimmer {
  0% {
    background-position: -200px 0;
  }
  100% {
    background-position: 200px 0;
  }
}
`;
document.head.appendChild(style);