import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
} from "recharts";

function ClaimsByCustomerChart({ claims }) {
  // Count claims per customer
  const customerMap = {};

  claims.forEach((claim) => {
    customerMap[claim.customer] =
      (customerMap[claim.customer] || 0) + 1;
  });

  // Convert to array & take top 5
  const data = Object.entries(customerMap)
    .map(([customer, count]) => ({ customer, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5);

  return (
    <div style={styles.card}>
      <h3 style={styles.title}>Top Claimants</h3>

      <ResponsiveContainer width="100%" height={260}>
        <BarChart data={data} layout="vertical">
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />

          <XAxis
            type="number"
            allowDecimals={false}
            tick={{ fill: "#e6f6ff", fontSize: 12 }}
          />

          <YAxis
            type="category"
            dataKey="customer"
            tick={{ fill: "#e6f6ff", fontSize: 12 }}
            width={140}
          />

          <Tooltip
            contentStyle={{
              backgroundColor: "#203a43",
              border: "none",
              color: "#fff",
              borderRadius: 8,
            }}
          />

          <Bar
            dataKey="count"
            fill="#00e0ff"
            radius={[0, 6, 6, 0]}
          />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

const styles = {
  card: {
    background: "linear-gradient(135deg, #2a536b, #346c89)",
    padding: "22px",
    borderRadius: "16px",
    boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
    color: "#fff",
  },
  title: {
    marginBottom: "10px",
    fontSize: "18px",
    fontWeight: "600",
  },
};

export default ClaimsByCustomerChart;