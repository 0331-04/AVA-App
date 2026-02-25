function Button({ variant = "primary", children, ...props }) {
  return (
    <button style={{ ...styles.base, ...styles[variant] }} {...props}>
      {children}
    </button>
  );
}

const styles = {
  base: {
    padding: "12px 24px",
    borderRadius: "10px",
    border: "none",
    cursor: "pointer",
    fontSize: "14px",
    fontWeight: 500,
  },
  primary: {
    background: "#27ae60",
    color: "#fff",
  },
  warning: {
    background: "#f39c12",
    color: "#fff",
  },
  danger: {
    background: "#c0392b",
    color: "#fff",
  },
};

export default Button;