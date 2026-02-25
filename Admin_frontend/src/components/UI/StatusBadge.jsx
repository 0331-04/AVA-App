function StatusBadge({ status }) {
  const colors = {
    Approved: "#27ae60",
    Pending: "#f39c12",
    Rejected: "#c0392b",
    "Under Review": "#2980b9",
  };

  return (
    <span
      style={{
        padding: "6px 16px",
        borderRadius: "20px",
        background: colors[status] || "#777",
        color: "#fff",
        fontSize: "13px",
        fontWeight: 500,
      }}
    >
      {status}
    </span>
  );
}

export default StatusBadge;