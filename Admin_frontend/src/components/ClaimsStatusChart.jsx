import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

const COLORS = ["#f39c12", "#27ae60", "#2980b9"];

function ClaimsStatusChart({ claims }) {
  const data = [
    {
      name: "Pending",
      value: claims.filter(c => c.status === "Pending").length,
    },
    {
      name: "Approved",
      value: claims.filter(c => c.status === "Approved").length,
    },
    {
      name: "Under Review",
      value: claims.filter(c => c.status === "Under Review").length,
    },
  ];

  return (
    <div
      style={{
        height: 300,
        background: "linear-gradient(135deg, #2a536b, #346c89)",
        borderRadius: 16,
        padding: 20,
        boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
        color: "#fff",
      }}
    >
      <h3 style={{ marginBottom: 10 }}>Claims by Status</h3>

      <ResponsiveContainer width="100%" height="85%">
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            outerRadius={90}
            dataKey="value"
            label
          >
            {data.map((_, index) => (
              <Cell key={index} fill={COLORS[index]} />
            ))}
          </Pie>
          <Tooltip />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}

export default ClaimsStatusChart;