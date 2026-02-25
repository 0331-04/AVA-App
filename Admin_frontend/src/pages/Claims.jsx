import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Layout from "../components/Layout";
import { useAuth } from "../context/AuthContext";

function Claims() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const role = user?.role;

  const claims = [
    { id: 101, customer: "John Silva", vehicle: "Toyota Corolla", status: "Pending", estimate: 120000 },
    { id: 102, customer: "Nimal Perera", vehicle: "Honda Civic", status: "Approved", estimate: 85000 },
    { id: 103, customer: "Kasun Fernando", vehicle: "Nissan X-Trail", status: "Under Review", estimate: 150000 },
    { id: 104, customer: "Amal Jayasinghe", vehicle: "Suzuki Alto", status: "Approved", estimate: 45000 },
    { id: 105, customer: "Sachini Peris", vehicle: "Toyota Aqua", status: "Pending", estimate: 98000 },
    { id: 106, customer: "Ruwan De Silva", vehicle: "Mitsubishi Montero", status: "Under Review", estimate: 320000 },
    { id: 107, customer: "Tharindu Lakmal", vehicle: "Honda Fit", status: "Approved", estimate: 76000 },
    { id: 108, customer: "Isuru Fernando", vehicle: "Toyota Hilux", status: "Pending", estimate: 210000 },
  ];

  /* Filters */
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");
  const [vehicleFilter, setVehicleFilter] = useState("All");
  const [minEstimate, setMinEstimate] = useState("");
  const [maxEstimate, setMaxEstimate] = useState("");

  /* Bulk selection */
  const [selectedIds, setSelectedIds] = useState([]);

  const vehicles = ["All", ...new Set(claims.map((c) => c.vehicle))];

  const filteredClaims = claims.filter((c) => {
    const matchesSearch =
      c.customer.toLowerCase().includes(search.toLowerCase()) ||
      c.vehicle.toLowerCase().includes(search.toLowerCase()) ||
      c.id.toString().includes(search);

    const matchesStatus = statusFilter === "All" || c.status === statusFilter;
    const matchesVehicle = vehicleFilter === "All" || c.vehicle === vehicleFilter;
    const matchesMin = minEstimate === "" || c.estimate >= Number(minEstimate);
    const matchesMax = maxEstimate === "" || c.estimate <= Number(maxEstimate);

    return matchesSearch && matchesStatus && matchesVehicle && matchesMin && matchesMax;
  });

  const toggleSelect = (id) => {
    setSelectedIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  return (
    <Layout>
      <div style={styles.page}>
        <div style={styles.container}>
          <h1 style={styles.heading}>Claims</h1>

          {/* 🔍 Filters */}
          <div style={styles.filters}>
            <input
              placeholder="Search by claim ID, customer, vehicle"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={styles.input}
            />

            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} style={styles.input}>
              <option value="All">All Status</option>
              <option value="Pending">Pending</option>
              <option value="Approved">Approved</option>
              <option value="Under Review">Under Review</option>
            </select>

            <select value={vehicleFilter} onChange={(e) => setVehicleFilter(e.target.value)} style={styles.input}>
              {vehicles.map((v) => (
                <option key={v}>{v}</option>
              ))}
            </select>

            <input
              type="number"
              placeholder="Min Estimate"
              value={minEstimate}
              onChange={(e) => setMinEstimate(e.target.value)}
              style={styles.input}
            />

            <input
              type="number"
              placeholder="Max Estimate"
              value={maxEstimate}
              onChange={(e) => setMaxEstimate(e.target.value)}
              style={styles.input}
            />
          </div>

          {/* Bulk actions */}
          {selectedIds.length > 0 && role !== "viewer" && (
            <div style={styles.bulkBar}>
              <span>{selectedIds.length} selected</span>
              <button
                disabled={role !== "admin"}
                style={{
                  ...styles.bulkBtn,
                  opacity: role !== "admin" ? 0.5 : 1,
                  cursor: role !== "admin" ? "not-allowed" : "pointer",
                }}
              >
                Export Selected
              </button>
            </div>
          )}

          {/* Table */}
          <div style={styles.tableContainer}>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th></th>
                  <th>Claim ID</th>
                  <th>Customer</th>
                  <th>Vehicle</th>
                  <th>Status</th>
                  <th>Estimate</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {filteredClaims.map((c) => (
                  <tr key={c.id}>
                    <td>
                      <input
                        type="checkbox"
                        disabled={role === "viewer"}
                        checked={selectedIds.includes(c.id)}
                        onChange={() => toggleSelect(c.id)}
                      />
                    </td>
                    <td>{c.id}</td>
                    <td>{c.customer}</td>
                    <td>{c.vehicle}</td>
                    <td>
                      <span style={statusStyle(c.status)}>{c.status}</span>
                    </td>
                    <td>Rs. {c.estimate.toLocaleString()}</td>
                    <td>
                      <button style={styles.viewBtn} onClick={() => navigate(`/claims/${c.id}`)}>
                        View
                      </button>
                    </td>
                  </tr>
                ))}

                {filteredClaims.length === 0 && (
                  <tr>
                    <td colSpan="7" style={{ textAlign: "center", padding: "20px" }}>
                      No claims found
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layout>
  );
}

/* Status badge */
function statusStyle(status) {
  return {
    padding: "6px 14px",
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
    background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
  },
  container: {
    maxWidth: "1200px",
    margin: "0 auto",
    color: "#fff",
  },
  heading: {
    fontSize: "30px",
    marginBottom: "20px",
  },
  filters: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
    gap: "16px",
    marginBottom: "24px",
  },
  input: {
    padding: "14px 16px",
    borderRadius: "10px",
    border: "none",
    fontSize: "15px",
  },
  bulkBar: {
    display: "flex",
    justifyContent: "space-between",
    marginBottom: "15px",
  },
  bulkBtn: {
    padding: "8px 18px",
    borderRadius: "8px",
    border: "none",
  },
  tableContainer: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "22px",
    borderRadius: "16px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
  },
  table: {
    width: "100%",
    borderCollapse: "collapse",
  },
  viewBtn: {
    padding: "6px 14px",
    borderRadius: "6px",
    border: "none",
    cursor: "pointer",
  },
};

export default Claims;