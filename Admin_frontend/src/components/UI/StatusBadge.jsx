function StatusBadge({ status }) {

  const getStyle = () => {
    switch (status) {
      case "Approved":
        return styles.approved;
      case "Pending":
        return styles.pending;
      case "Under Review":
        return styles.review;
      case "Rejected":
        return styles.rejected;
      default:
        return styles.default;
    }
  };

  return (
    <span style={{ ...styles.badge, ...getStyle() }}>
      {status}
    </span>
  );
}

const styles = {
  badge: {
    padding: "6px 14px",
    borderRadius: "20px",
    fontSize: "12px",
    fontWeight: "600",
    letterSpacing: "0.3px",
    display: "inline-block",
  },

  approved: {
    background: "#27ae60",
    color: "#fff",
  },

  pending: {
    background: "#f39c12",
    color: "#fff",
  },

  review: {
    background: "#2980b9",
    color: "#fff",
  },

  rejected: {
    background: "#c0392b",
    color: "#fff",
  },

  default: {
    background: "#7f8c8d",
    color: "#fff",
  },
};

export default StatusBadge;