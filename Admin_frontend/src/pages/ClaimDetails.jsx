import { useParams, useNavigate } from "react-router-dom";
import Sidebar from "../components/Sidebar";
import { useState } from "react";

function ClaimDetails() {
  const { id } = useParams();
  const navigate = useNavigate();

  // Dummy claim (later comes from backend)
  const claim = {
    id,
    customer: "Isuru Fernando",
    contact: "077-1234567",
    vehicle: "Toyota Hilux",
    plate: "CAB-2345",
    year: 2019,
    status: "Pending",
    mlEstimate: 210000,
    images: [
      "https://via.placeholder.com/300x200?text=Damage+1",
      "https://via.placeholder.com/300x200?text=Damage+2",
      "https://via.placeholder.com/300x200?text=Damage+3",
    ],
  };

  const [estimate, setEstimate] = useState(claim.mlEstimate);
  const [status, setStatus] = useState(claim.status);

  return (
    <div style={styles.layout}>
      <Sidebar />

      <main style={styles.content}>
        <div style={styles.container}>
          <button style={styles.backBtn} onClick={() => navigate(-1)}>
            ← Back to Claims
          </button>

          <h1 style={styles.heading}>Claim #{claim.id}</h1>

          {/* 🧾 Info Cards */}
          <div style={styles.cards}>
            <InfoCard title="Customer Details">
              <p><b>Name:</b> {claim.customer}</p>
              <p><b>Contact:</b> {claim.contact}</p>
            </InfoCard>

            <InfoCard title="Vehicle Details">
              <p><b>Vehicle:</b> {claim.vehicle}</p>
              <p><b>Plate:</b> {claim.plate}</p>
              <p><b>Year:</b> {claim.year}</p>
            </InfoCard>
          </div>

          {/* 📷 Damage Images */}
          <div style={styles.section}>
            <h3>Damage Images</h3>
            <div style={styles.images}>
              {claim.images.map((img, i) => (
                <img key={i} src={img} alt="Damage" style={styles.image} />
              ))}
            </div>
          </div>

          {/* 🤖 ML Estimate */}
          <div style={styles.section}>
            <h3>ML Estimated Cost</h3>
            <input
              type="number"
              value={estimate}
              onChange={(e) => setEstimate(e.target.value)}
              style={styles.input}
            />
            <p style={styles.note}>
              Agent can modify this estimate if required
            </p>
          </div>

          {/* 🧑‍💼 Actions */}
          <div style={styles.actions}>
            <button
              style={styles.approve}
              onClick={() => setStatus("Approved")}
            >
              Approve
            </button>

            <button
              style={styles.review}
              onClick={() => setStatus("Under Review")}
            >
              Under Review
            </button>

            <button
              style={styles.reject}
              onClick={() => setStatus("Rejected")}
            >
              Reject
            </button>
          </div>

          <p style={styles.status}>
            Current Status: <b>{status}</b>
          </p>
        </div>
      </main>
    </div>
  );
}

/* 🧱 Reusable Card */
function InfoCard({ title, children }) {
  return (
    <div style={styles.card}>
      <h3>{title}</h3>
      {children}
    </div>
  );
}

/* 🎨 Styles */
const styles = {
  layout: { display: "flex", minHeight: "100vh" },
  content: {
    flex: 1,
    marginLeft: "220px",
    padding: "30px",
    background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
  },
  container: { maxWidth: "1100px", margin: "0 auto", color: "#fff" },
  backBtn: {
    marginBottom: "15px",
    background: "transparent",
    color: "#00e0ff",
    border: "none",
    cursor: "pointer",
  },
  heading: { fontSize: "28px", marginBottom: "20px" },

  cards: {
    display: "grid",
    gridTemplateColumns: "1fr 1fr",
    gap: "20px",
  },
  card: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "20px",
    borderRadius: "16px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
  },

  section: {
    marginTop: "30px",
  },

  images: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
    gap: "15px",
    marginTop: "15px",
  },
  image: {
    width: "100%",
    borderRadius: "12px",
  },

  input: {
    marginTop: "10px",
    padding: "10px",
    borderRadius: "8px",
    border: "none",
    width: "200px",
  },
  note: {
    fontSize: "13px",
    opacity: 0.8,
  },

  actions: {
    marginTop: "30px",
    display: "flex",
    gap: "15px",
  },
  approve: {
    background: "#27ae60",
    border: "none",
    color: "#fff",
    padding: "10px 20px",
    borderRadius: "8px",
    cursor: "pointer",
  },
  review: {
    background: "#f39c12",
    border: "none",
    color: "#fff",
    padding: "10px 20px",
    borderRadius: "8px",
    cursor: "pointer",
  },
  reject: {
    background: "#c0392b",
    border: "none",
    color: "#fff",
    padding: "10px 20px",
    borderRadius: "8px",
    cursor: "pointer",
  },

  status: {
    marginTop: "20px",
    fontSize: "16px",
  },
};

export default ClaimDetails;