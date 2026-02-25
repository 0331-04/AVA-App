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

  /* 🔹 Sorting */
  const [sortConfig, setSortConfig] = useState({
    key: null,
    direction: "asc",
  });

  const handleSort = (key) => {
    setSortConfig((prev) => {
      if (prev.key === key) {
        return {
          key,
          direction: prev.direction === "asc" ? "desc" : "asc",
        };
      }
      return { key, direction: "asc" };
    });
  };

  /* 🔹 Filter + Sort */
  const filteredClaims = [...claims]
    .filter((c) => {
      const matchesSearch =
        c.customer.toLowerCase().includes(search.toLowerCase()) ||
        c.vehicle.toLowerCase().includes(search.toLowerCase()) ||
        c.id.toString().includes(search);

      const matchesStatus =
        statusFilter === "All" || c.status === statusFilter;

      return matchesSearch && matchesStatus;
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

  return (
    <Layout>
      <div style={styles.content}>
        <div style={styles.container}>
          <h1 style={styles.heading}>Claims</h1>

          {/* 🔍 Search & Filter */}
          <div style={styles.filters}>
            <input
              type="text"
              placeholder="Search by Claim ID, Customer, Vehicle"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={styles.search}
            />

            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              style={styles.select}
            >
              <option value="All">All Status</option>
              <option value="Pending">Pending</option>
              <option value="Approved">Approved</option>
              <option value="Under Review">Under Review</option>
            </select>
          </div>

          {/* 📋 Claims Table */}
          <div style={styles.tableContainer}>
            <table style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.th} onClick={() => handleSort("id")}>
                    Claim ID {sortConfig.key === "id" ? (sortConfig.direction === "asc" ? "▲" : "▼") : ""}
                  </th>
                  <th style={styles.th} onClick={() => handleSort("customer")}>
                    Customer {sortConfig.key === "customer" ? (sortConfig.direction === "asc" ? "▲" : "▼") : ""}
                  </th>
                  <th style={styles.th} onClick={() => handleSort("vehicle")}>
                    Vehicle {sortConfig.key === "vehicle" ? (sortConfig.direction === "asc" ? "▲" : "▼") : ""}
                  </th>
                  <th style={styles.th} onClick={() => handleSort("status")}>
                    Status {sortConfig.key === "status" ? (sortConfig.direction === "asc" ? "▲" : "▼") : ""}
                  </th>
                  <th style={styles.th} onClick={() => handleSort("estimate")}>
                    Estimate {sortConfig.key === "estimate" ? (sortConfig.direction === "asc" ? "▲" : "▼") : ""}
                  </th>
                  <th style={styles.th}>Action</th>
                </tr>
              </thead>

              <tbody>
                {filteredClaims.length === 0 ? (
                  <tr>
                    <td colSpan="6" style={styles.empty}>
                      No claims found
                    </td>
                  </tr>
                ) : (
                  filteredClaims.map((c) => (
                    <tr
                      key={c.id}
                      onMouseEnter={(e) =>
                        (e.currentTarget.style.background = styles.rowHover.background)
                      }
                      onMouseLeave={(e) =>
                        (e.currentTarget.style.background = "transparent")
                      }
                    >
                      <td style={styles.td}>{c.id}</td>
                      <td style={styles.td}>{c.customer}</td>
                      <td style={styles.td}>{c.vehicle}</td>
                      <td style={styles.td}>
                        <span style={statusStyle(c.status)}>{c.status}</span>
                      </td>
                      <td style={styles.td}>
                        Rs. {c.estimate.toLocaleString()}
                      </td>
                      <td style={styles.td}>
                        <button
                          style={styles.viewBtn}
                          onClick={() => navigate(`/claims/${c.id}`)}
                        >
                          View
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layout>
  );
}

/* 🎨 Status badge */
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

/* 🎨 Styles */
const styles = {
  content: {
    padding: "30px",
    background: "linear-gradient(135deg, #0f2027, #203a43, #2c5364)",
    minHeight: "100vh",
  },

  container: {
    maxWidth: "1200px",
    margin: "0 auto",
  },

  heading: {
    color: "#fff",
    marginBottom: "20px",
    fontSize: "28px",
    fontWeight: "600",
  },

  filters: {
    display: "flex",
    gap: "15px",
    marginBottom: "20px",
  },

  search: {
    flex: 1,
    padding: "10px 14px",
    borderRadius: "8px",
    border: "none",
    outline: "none",
  },

  select: {
    padding: "10px 14px",
    borderRadius: "8px",
    border: "none",
    outline: "none",
  },

  tableContainer: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "22px",
    borderRadius: "16px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
    color: "#fff",
  },

  table: {
    width: "100%",
    borderCollapse: "collapse",
  },

  th: {
    padding: "12px",
    background: "rgba(255,255,255,0.12)",
    textAlign: "left",
    cursor: "pointer",
    userSelect: "none",
  },

  td: {
    padding: "12px",
    borderBottom: "1px solid rgba(255,255,255,0.12)",
  },

  rowHover: {
    background: "rgba(255,255,255,0.08)",
  },

  empty: {
    padding: "20px",
    textAlign: "center",
    color: "#e6f6ff",
  },

  viewBtn: {
    padding: "6px 14px",
    borderRadius: "6px",
    background: "#203a43",
    color: "#fff",
    border: "none",
    cursor: "pointer",
  },
};

export default Claims;