function PageHeader({ title, subtitle, right }) {
  return (
    <div style={styles.header}>
      <div>
        <h1 style={styles.title}>{title}</h1>
        {subtitle && <p style={styles.subtitle}>{subtitle}</p>}
      </div>
      {right}
    </div>
  );
}

const styles = {
  header: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: "30px",
  },
  title: {
    fontSize: "32px",
    fontWeight: 600,
    color: "#fff",
  },
  subtitle: {
    fontSize: "14px",
    opacity: 0.8,
  },
};

export default PageHeader;