function Card({ title, children }) {
  return (
    <div style={styles.card}>
      {title && <h3 style={styles.title}>{title}</h3>}
      {children}
    </div>
  );
}

const styles = {
  card: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "22px",
    borderRadius: "18px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
    color: "#fff",
  },
  title: {
    fontSize: "18px",
    marginBottom: "12px",
  },
};

export default Card;