import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Layout from "../components/Layout";

function Claims() {
  const navigate = useNavigate();

  // Dummy claims data
  const claims = [
    { id: 101, customer: "John Silva", vehicle: "Toyota Corolla", status: "Pending", estimate: 120000 },
    { id: 102, customer: "Nimal Perera", vehicle: "Honda Civic", status: "Approved", estimate: 85000 },
    { id: 103, customer: "Kasun Fernando", vehicle: "Nissan X-Trail", status: "Under Review", estimate: 150000 },
    { id: 104, customer: "Amal Jayasinghe", vehicle: "Suzuki Alto", status: "Approved", estimate: 45000 },
    { id: 105, customer: "Sachini Peris", vehicle: "Toyota Aqua", status: "Pending", estimate: 98000 },
    { id: 106, customer: "Ruwan De Silva", vehicle: "Mitsubishi Montero", status: "Under Review", estimate: 320000 },
    { id: 107, customer: "Tharindu Lakmal", vehicle: "Honda Fit", status: "Approved", estimate: 76000 },
    { id: 108, customer: "Isuru Fernando", vehicle: "Toyota Hilux", status: "Pending", estimate: 210000 },
    { id: 109, customer: "Dinuka Wijesinghe", vehicle: "BMW 320i", status: "Under Review", estimate: 480000 },
  ];

  /* 🔹 Filters */
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");
  const [vehicleFilter, setVehicleFilter] = useState("All");
  const [minEstimate, setMinEstimate] = useState("");
  const [maxEstimate, setMaxEstimate] = useState("");

  /* 🔹 Sorting */
  const [sortConfig, setSortConfig] = useState({ key: null, direction: "asc" });

  /* 🔹 Pagination */
  const [currentPage, setCurrentPage] = useState(1);
  const rowsPerPage = 5;

  const handleSort = (key) => {
    setSortConfig((prev) => {
      if (prev.key === key) {
        return { key, direction: prev.direction === "asc" ? "desc" : "asc" };
      }
      return { key, direction: "asc" };
    });
  };

  /* 🔹 Filter + Sort */
  const processedClaims = [...claims]
    .filter((c) => {
      const matchesSearch =
        c.customer.toLowerCase().includes(search.toLowerCase()) ||
        c.vehicle.toLowerCase().includes(search.toLowerCase()) ||
        c.id.toString().includes(search);

      const matchesStatus =
        statusFilter === "All" || c.status === statusFilter;

      const matchesVehicle =
        vehicleFilter === "All" || c.vehicle === vehicleFilter;

      const matchesMin =
        minEstimate === "" || c.estimate >= Number(minEstimate);

      const matchesMax =
        maxEstimate === "" || c.estimate <= Number(maxEstimate);

      return (
        matchesSearch &&
        matchesStatus &&
        matchesVehicle &&
        matchesMin &&
        matchesMax
      );
    })
    .sort((a, b) => {
      if (!sortConfig.key) return 0;

      const aVal = a[sortConfig.key];
      const bVal = b[sortConfig.key];

      if (typeof aVal === "number") {
        return sortConfig.direction === "asc"
          ? aVal - bVal
          : bVal - aVal;
      }

      return sortConfig.direction === "asc"
        ? aVal.localeCompare(bVal)
        : bVal.localeCompare(aVal);
    });

  /* 🔹 Pagination */
  const totalPages = Math.ceil(processedClaims.length / rowsPerPage);
  const startIndex = (currentPage - 1) * rowsPerPage;
  const paginatedClaims = processedClaims.slice(
    startIndex,
    startIndex + rowsPerPage
  );

  const vehicles = ["All", ...new Set(claims.map((c) => c.vehicle))];

  return (
    <Layout>
      <div style={styles.content}>
        <div style={styles.container}>
          <h1 style={styles.heading}>Claims</h1>

          {/* 🔍 Filters */}
          <div style={styles.filters}>
            <input
              placeholder="Search"
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setCurrentPage(1);
              }}
              style={styles.input}
            />

            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value);
                setCurrentPage(1);
              }}
              style={styles.input}
            >
              <option value="All">All Status</option>
              <option value="Pending">Pending</option>
              <option value="Approved">Approved</option>
              <option value="Under Review">Under Review</option>
            </select>

            <select
              value={vehicleFilter}
              onChange={(e) => {
                setVehicleFilter(e.target.value);
                setCurrentPage(1);
              }}
              style={styles.input}
            >
              {vehicles.map((v) => (
                <option key={v} value={v}>{v}</option>
              ))}
            </select>

            <input
              type="number"
              placeholder="Min Rs"
              value={minEstimate}
              onChange={(e) => {
                setMinEstimate(e.target.value);
                setCurrentPage(1);
              }}
              style={styles.input}
            />

            <input
              type="number"
              placeholder="Max Rs"
              value={maxEstimate}
              onChange={(e) => {
                setMaxEstimate(e.target.value);
                setCurrentPage(1);
              }}
              style={styles.input}
            />
          </div>

          {/* 📋 Table */}
          <div style={styles.tableContainer}>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th onClick={() => handleSort("id")}>ID</th>
                  <th onClick={() => handleSort("customer")}>Customer</th>
                  <th onClick={() => handleSort("vehicle")}>Vehicle</th>
                  <th onClick={() => handleSort("status")}>Status</th>
                  <th onClick={() => handleSort("estimate")}>Estimate</th>
                  <th>Action</th>
                </tr>
              </thead>

              <tbody>
                {paginatedClaims.map((c) => (
                  <tr key={c.id}>
                    <td>{c.id}</td>
                    <td>{c.customer}</td>
                    <td>{c.vehicle}</td>
                    <td>
                      <span style={statusStyle(c.status)}>{c.status}</span>
                    </td>
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

            {/* Pagination */}
            <div style={styles.pagination}>
              <button
                disabled={currentPage === 1}
                onClick={() => setCurrentPage((p) => p - 1)}
              >
                Previous
              </button>

              <span>
                Page {currentPage} of {totalPages}
              </span>

              <button
                disabled={currentPage === totalPages}
                onClick={() => setCurrentPage((p) => p + 1)}
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}

/* Status badge */
function statusStyle(status) {
  return {
    padding: "4px 10px",
    borderRadius: "20px",
    color: "#fff",
    fontSize: "12px",
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
  content: {
    padding: "30px",
    background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
    minHeight: "100vh",
  },
  container: { maxWidth: "1200px", margin: "0 auto" },
  heading: { color: "#fff", marginBottom: "20px", fontSize: "28px" },

  filters: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))",
    gap: "12px",
    marginBottom: "20px",
  },

  input: {
    padding: "10px",
    borderRadius: "8px",
    border: "none",
  },

  tableContainer: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "20px",
    borderRadius: "16px",
    color: "#fff",
  },

  table: { width: "100%", borderCollapse: "collapse" },

  pagination: {
    marginTop: "16px",
    display: "flex",
    justifyContent: "space-between",
  },

  viewBtn: {
    padding: "6px 14px",
    borderRadius: "6px",
    border: "none",
    cursor: "pointer",
  },
};

export default Claims;