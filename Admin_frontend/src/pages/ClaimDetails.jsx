import { useParams, useNavigate } from "react-router-dom";
import Sidebar from "../components/Sidebar";
import { useState } from "react";

function ClaimDetails() {
  const { id } = useParams();
  const navigate = useNavigate();

  /* 🔹 Mock claim data (later from backend) */
  const claim = {
    id,
    customer: "Isuru Fernando",
    contact: "077-1234567",
    vehicle: "Toyota Hilux",
    plate: "CAB-2345",
    year: 2019,

    status: "Pending",

    ml: {
      estimate: 210000,
      confidence: 82,
      damages: ["Front bumper", "Left door", "Headlamp"],
    },

    images: [
      "https://via.placeholder.com/300x200?text=Damage+1",
      "https://via.placeholder.com/300x200?text=Damage+2",
      "https://via.placeholder.com/300x200?text=Damage+3",
    ],

    history: [
      { status: "Submitted", by: "Customer", date: "2026-02-10 09:14" },
      { status: "AI Estimate Generated", by: "AVA AI Engine", date: "2026-02-10 09:15" },
      { status: "Pending", by: "System", date: "2026-02-10 09:15" },
    ],
  };

  /* 🔹 State */
  const [status, setStatus] = useState(claim.status);
  const [estimate, setEstimate] = useState(claim.ml.estimate);
  const [overrideReason, setOverrideReason] = useState("");
  const [history, setHistory] = useState(claim.history);

  /* 🔹 Handle status update */
  const updateStatus = (newStatus) => {
    setStatus(newStatus);
    setHistory([
    ...history,
    {
      status: newStatus,
      by: "Agent",
      date: new Date().toLocaleString(),
    },
  ]);
};

  return (
    <div style={styles.layout}>
      <Sidebar />

      <main style={styles.content}>
        <div style={styles.container}>
          <button style={styles.backBtn} onClick={() => navigate(-1)}>
            ← Back to Claims
          </button>

          <h1 style={styles.heading}>Claim #{claim.id}</h1>

          {/* 🧾 INFO CARDS */}
          <div style={styles.cards}>
            <Card title="Customer Details">
              <p><b>Name:</b> {claim.customer}</p>
              <p><b>Contact:</b> {claim.contact}</p>
            </Card>

            <Card title="Vehicle Details">
              <p><b>Vehicle:</b> {claim.vehicle}</p>
              <p><b>Plate:</b> {claim.plate}</p>
              <p><b>Year:</b> {claim.year}</p>
            </Card>
          </div>

          {/* 📷 DAMAGE IMAGES */}
          <Section title="Damage Images">
            <div style={styles.images}>
              {claim.images.map((img, i) => (
                <img key={i} src={img} alt="Damage" style={styles.image} />
              ))}
            </div>
          </Section>

          {/* 🤖 ML ESTIMATE */}
          <Section title="ML Assessment">
            <p><b>Estimated Cost:</b></p>
            <input
              type="number"
              value={estimate}
              onChange={(e) => setEstimate(e.target.value)}
              style={styles.input}
            />

            <p style={styles.note}>
              Confidence: <b>{claim.ml.confidence}%</b>
            </p>

            <p><b>Detected Damages:</b></p>
            <ul>
              {claim.ml.damages.map((d, i) => (
                <li key={i}>{d}</li>
              ))}
            </ul>

            <textarea
              placeholder="Reason for manual override (required if modified)"
              value={overrideReason}
              onChange={(e) => setOverrideReason(e.target.value)}
              style={styles.textarea}
            />
          </Section>

          {/* 🕒 CLAIM TIMELINE */}
          <Section title="Claim Timeline">
            <div style={styles.timeline}>
              {history.map((h, i) => (
                <div key={i} style={styles.timelineItem}>
                  <div style={styles.timelineDot} />
                  <div>
                    <p><b>{h.status}</b></p>
                    <p style={styles.timelineMeta}>
                      {h.by} • {h.date}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </Section>

          {/* 🧑‍💼 ACTIONS */}
          <div style={styles.actions}>
            <button style={styles.approve} onClick={() => updateStatus("Approved")}>
              Approve
            </button>
            <button style={styles.review} onClick={() => updateStatus("Under Review")}>
              Under Review
            </button>
            <button style={styles.reject} onClick={() => updateStatus("Rejected")}>
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

/* 🔹 Reusable Components */
function Card({ title, children }) {
  return (
    <div style={styles.card}>
      <h3>{title}</h3>
      {children}
    </div>
  );
}

function Section({ title, children }) {
  return (
    <div style={styles.section}>
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

  section: { marginTop: "30px" },

  images: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
    gap: "15px",
  },
  image: { width: "100%", borderRadius: "12px" },

  input: {
    marginTop: "8px",
    padding: "10px",
    borderRadius: "8px",
    border: "none",
    width: "220px",
  },
  textarea: {
    marginTop: "12px",
    padding: "10px",
    borderRadius: "8px",
    width: "100%",
    minHeight: "80px",
    border: "none",
  },
  note: { fontSize: "13px", opacity: 0.85 },

  timeline: {
    marginTop: "15px",
    borderLeft: "2px solid #00e0ff",
    paddingLeft: "20px",
  },
  timelineItem: {
    marginBottom: "15px",
    position: "relative",
  },
  timelineDot: {
    position: "absolute",
    left: "-11px",
    top: "6px",
    width: "10px",
    height: "10px",
    background: "#00e0ff",
    borderRadius: "50%",
  },
  timelineMeta: { fontSize: "12px", opacity: 0.8 },

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

  status: { marginTop: "20px", fontSize: "16px" },
};

export default ClaimDetails;