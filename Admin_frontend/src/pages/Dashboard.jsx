import { useNavigate } from "react-router-dom";

function Dashboard() {
  const navigate = useNavigate();

  // Mock claim data
  const claims = [
    {
      id: 101,
      customer: "John Silva",
      vehicle: "Toyota Corolla",
      status: "Pending",
      estimate: 120000,
    },
    {
      id: 102,
      customer: "Nimal Perera",
      vehicle: "Honda Civic",
      status: "Approved",
      estimate: 85000,
    },
    {
      id: 103,
      customer: "Kasun Fernando",
      vehicle: "Nissan X-Trail",
      status: "Under Review",
      estimate: 150000,
    },
  ];

  return (
  <div style={styles.page}>
    <div style={styles.container}>
      <h1 style={styles.heading}>Admin Dashboard</h1>

      {/* KPI Widgets */}
      <div style={styles.widgets}>
        <Widget title="Total Claims" value={claims.length} />
        <Widget title="Pending Claims" value={claims.filter(c => c.status === "Pending").length} />
        <Widget title="Approved Claims" value={claims.filter(c => c.status === "Approved").length} />
        <Widget
          title="Total ML Estimate"
          value={`Rs. ${claims.reduce((a, c) => a + c.estimate, 0).toLocaleString()}`}
        />
      </div>

      {/* Claims Table */}
      <div style={styles.tableContainer}>
        <h3>Recent Claims</h3>

        <table style={styles.table}>
          <thead>
            <tr>
              <th>Claim ID</th>
              <th>Customer</th>
              <th>Vehicle</th>
              <th>Status</th>
              <th>ML Estimate</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {claims.map((c) => (
              <tr key={c.id}>
                <td>{c.id}</td>
                <td>{c.customer}</td>
                <td>{c.vehicle}</td>
                <td><span style={statusStyle(c.status)}>{c.status}</span></td>
                <td>Rs. {c.estimate.toLocaleString()}</td>
                <td>
                  <button
                    style={styles.viewBtn}
                    onClick={() => navigate(`/claims/${c.id}`)}
                  >
                    View
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  </div>
);
}

/* KPI Widget Component */
function Widget({ title, value }) {
  return (
    <div style={styles.widget}>
      <p style={styles.widgetTitle}>{title}</p>
      <h2 style={styles.widgetValue}>{value}</h2>
    </div>
  );
}

/* Status badge colors */
function statusStyle(status) {
  return {
    padding: "6px 12px",
    borderRadius: "20px",
    fontSize: "12px",
    color: "#fff",
    background:
      status === "Approved"
        ? "#27ae60"
        : status === "Pending"
        ? "#f39c12"
        : "#2980b9",
  };
}

/* Styles */
const styles = {
  page: {
    padding: "30px",
    minHeight: "100vh",
    background: "#f5f7fa",
  },
  heading: {
    marginBottom: "25px",
  },
  widgets: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
    gap: "20px",
    marginBottom: "35px",
  },
  widget: {
    background: "#fff",
    padding: "20px",
    borderRadius: "12px",
    boxShadow: "0 8px 20px rgba(0,0,0,0.08)",
  },
  widgetTitle: {
    fontSize: "14px",
    color: "#777",
  },
  widgetValue: {
    marginTop: "10px",
    color: "#203a43",
  },
  tableContainer: {
    background: "#fff",
    padding: "20px",
    borderRadius: "12px",
    boxShadow: "0 8px 20px rgba(0,0,0,0.08)",
  },
  table: {
    width: "100%",
    borderCollapse: "collapse",
    marginTop: "15px",
  },
  viewBtn: {
    padding: "6px 14px",
    border: "none",
    borderRadius: "6px",
    background: "#203a43",
    color: "#fff",
    cursor: "pointer",
  },
  container: {
  maxWidth: "1200px",     // keeps content neat
  margin: "0 auto",       // centers horizontally
  },
  page: {
  minHeight: "100vh",
  padding: "30px",
  background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
  },
};

export default Dashboard;