function Skeleton({ height = 20 }) {
  return (
    <div
      style={{
        height,
        background: "rgba(255,255,255,0.15)",
        borderRadius: "6px",
        marginBottom: "10px",
      }}
    />
  );
}

export default Skeleton;