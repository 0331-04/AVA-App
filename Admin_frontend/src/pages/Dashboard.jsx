import { useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import Layout from "../components/Layout";

import {
  MdDescription,
  MdHourglassTop,
  MdCheckCircle,
  MdTrendingUp,
  MdTaskAlt,
  MdAttachMoney
} from "react-icons/md";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  BarChart,
  Bar,
} from "recharts";

/* 🔢 Animated Counter */
function AnimatedNumber({ value, duration = 1200 }) {
  const [displayValue, setDisplayValue] = useState(0);

  useEffect(() => {
    let start = 0;
    const increment = value / (duration / 16);

    const timer = setInterval(() => {
      start += increment;
      if (start >= value) {
        setDisplayValue(value);
        clearInterval(timer);
      } else {
        setDisplayValue(Math.floor(start));
      }
    }, 16);

    return () => clearInterval(timer);
  }, [value, duration]);

  return <span>{displayValue}</span>;
}

/* 📦 KPI Widget */
function Widget({ title, value, icon, size = "large" }) {

  const isSmall = size === "small";

  return (
    <div style={isSmall ? styles.smallWidget : styles.widget}>
      <div style={styles.widgetAccent} />

      <div style={styles.widgetHeader}>
        <span style={styles.widgetIcon}>{icon}</span>
        <p style={styles.widgetTitle}>{title}</p>
      </div>

      <h2 style={isSmall ? styles.smallWidgetValue : styles.widgetValue}>
        <AnimatedNumber value={value} />
      </h2>
    </div>
  );
}

function Dashboard() {
  const navigate = useNavigate();
  const [range, setRange] = useState("Last 30 Days");

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

  /* Analytics calculations */

  const avgClaim =
    Math.round(
      claims.reduce((sum, c) => sum + c.estimate, 0) / claims.length
    );

  const approvalRate =
    Math.round(
      (claims.filter(c => c.status === "Approved").length / claims.length) * 100
    );

  const totalEstimate =
    claims.reduce((sum, c) => sum + c.estimate, 0);

  /* Chart Data */

  const claimsOverTime = [
    { month: "Jan", claims: 4 },
    { month: "Feb", claims: 6 },
    { month: "Mar", claims: 3 },
    { month: "Apr", claims: 8 },
    { month: "May", claims: 5 },
  ];

  const vehicleClaims = [
    { vehicle: "Toyota Corolla", count: 3 },
    { vehicle: "Honda Civic", count: 2 },
    { vehicle: "Toyota Hilux", count: 2 },
    { vehicle: "Suzuki Alto", count: 1 },
  ];

  return (
    <Layout>
      <div style={styles.content}>
        <div style={styles.container}>

          {/* Header */}
          <div style={styles.header}>
            <h1 style={styles.heading}>Admin Dashboard</h1>

            <select
              value={range}
              onChange={(e) => setRange(e.target.value)}
              style={styles.rangeSelect}
            >
              <option>Last 7 Days</option>
              <option>Last 30 Days</option>
              <option>This Month</option>
              <option>Last 6 Months</option>
            </select>
          </div>

          {/* Primary KPI Widgets */}
          <div style={styles.widgets}>
            <Widget title="Total Claims" value={claims.length} icon={<MdDescription />} />
            <Widget
              title="Pending Claims"
              value={claims.filter(c => c.status === "Pending").length}
              icon={<MdHourglassTop />}
            />
            <Widget
              title="Approved Claims"
              value={claims.filter(c => c.status === "Approved").length}
              icon={<MdCheckCircle />}
            />
          </div>

          {/* Smaller Analytics Cards */}
          <div style={styles.secondaryWidgets}>
            <Widget
              title="Avg Claim Value"
              value={avgClaim}
              icon={<MdTrendingUp />}
              size="small"
            />

            <Widget
              title="Approval Rate (%)"
              value={approvalRate}
              icon={<MdTaskAlt />}
              size="small"
            />

            <Widget
              title="Total Estimate"
              value={totalEstimate}
              icon={<MdAttachMoney />}
              size="small"
            />
          </div>

          {/* Charts */}
          <div style={styles.chartRow}>

            <div style={styles.chartCard}>
              <h3>Claims Over Time</h3>

              <ResponsiveContainer width="100%" height={260}>
                <LineChart data={claimsOverTime}>
                  <CartesianGrid stroke="rgba(255,255,255,0.1)" />
                  <XAxis dataKey="month" stroke="#e6f6ff" />
                  <YAxis stroke="#e6f6ff" />
                  <Tooltip />
                  <Line
                    type="monotone"
                    dataKey="claims"
                    stroke="#00e0ff"
                    strokeWidth={3}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>

            <div style={styles.chartCard}>
              <h3>Claims by Vehicle</h3>

              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={vehicleClaims} layout="vertical">
                  <CartesianGrid stroke="rgba(255,255,255,0.1)" />
                  <XAxis type="number" stroke="#e6f6ff" />
                  <YAxis
                    dataKey="vehicle"
                    type="category"
                    stroke="#e6f6ff"
                    width={120}
                  />
                  <Tooltip />
                  <Bar
                    dataKey="count"
                    fill="#00e0ff"
                    radius={[0, 6, 6, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>

          </div>

          {/* Claims Table */}
          <div style={styles.tableContainer}>
            <h3>Recent Claims</h3>

            <table style={styles.table}>
              <thead>
                <tr>
                  <th style={styles.th}>Claim ID</th>
                  <th style={styles.th}>Customer</th>
                  <th style={styles.th}>Vehicle</th>
                  <th style={styles.th}>Status</th>
                  <th style={styles.th}>Estimate</th>
                  <th style={styles.th}>Action</th>
                </tr>
              </thead>

              <tbody>
                {claims.map(c => (
                  <tr key={c.id}>
                    <td style={styles.td}>{c.id}</td>
                    <td style={styles.td}>{c.customer}</td>
                    <td style={styles.td}>{c.vehicle}</td>
                    <td style={styles.td}>
                      <span style={statusStyle(c.status)}>{c.status}</span>
                    </td>
                    <td style={styles.td}>Rs. {c.estimate.toLocaleString()}</td>
                    <td style={styles.td}>
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
          </div>

        </div>
      </div>
    </Layout>
  );
}

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

const styles = {

  content:{
    padding:"30px",
    background:"linear-gradient(135deg,#0f2027,#203a43,#2c5364)",
    minHeight:"100vh"
  },

  container:{
    maxWidth:"1200px",
    margin:"0 auto"
  },

  header:{
    display:"flex",
    justifyContent:"space-between",
    alignItems:"center",
    marginBottom:"24px"
  },

  rangeSelect:{
    padding:"8px 12px",
    borderRadius:"8px",
    border:"none"
  },

  heading:{
    color:"#fff",
    fontSize:"28px",
    fontWeight:"600"
  },

  widgets:{
    display:"grid",
    gridTemplateColumns:"repeat(auto-fit,minmax(240px,1fr))",
    gap:"20px",
    marginBottom:"20px"
  },

  secondaryWidgets:{
    display:"grid",
    gridTemplateColumns:"repeat(auto-fit,minmax(200px,1fr))",
    gap:"16px",
    marginBottom:"30px"
  },

  widget:{
    position:"relative",
    background:"linear-gradient(135deg,#2b556e,#356b88)",
    padding:"24px",
    borderRadius:"16px",
    boxShadow:"0 12px 30px rgba(0,0,0,0.25)",
    color:"#fff",
    textAlign:"center"
  },

  smallWidget:{
    position:"relative",
    background:"linear-gradient(135deg,#2b556e,#356b88)",
    padding:"18px",
    borderRadius:"14px",
    boxShadow:"0 8px 20px rgba(0,0,0,0.20)",
    color:"#fff",
    textAlign:"center"
  },

  widgetAccent:{
    position:"absolute",
    top:0,
    left:0,
    width:"100%",
    height:"6px",
    background:"linear-gradient(90deg,#00e0ff,#2c5364)",
    borderTopLeftRadius:"16px",
    borderTopRightRadius:"16px"
  },

  widgetHeader:{
    display:"flex",
    justifyContent:"center",
    gap:"10px"
  },

  widgetTitle:{
    fontSize:"18px",
    fontWeight:"600",
    color:"#e6f6ff"
  },

  widgetIcon:{fontSize:"22px"},

  widgetValue:{
    fontSize:"34px",
    fontWeight:"700",
    marginTop:"10px"
  },

  smallWidgetValue:{
    fontSize:"24px",
    fontWeight:"700",
    marginTop:"6px"
  },

  chartRow:{
    display:"grid",
    gridTemplateColumns:"1fr 1fr",
    gap:"20px",
    marginBottom:"30px"
  },

  chartCard:{
    background:"linear-gradient(135deg,#2a536b,#346c89)",
    padding:"22px",
    borderRadius:"16px",
    boxShadow:"0 12px 30px rgba(0,0,0,0.25)",
    color:"#fff"
  },

  tableContainer:{
    background:"linear-gradient(135deg,#2a536b,#346c89)",
    padding:"22px",
    borderRadius:"16px",
    boxShadow:"0 12px 30px rgba(0,0,0,0.25)",
    color:"#fff"
  },

  table:{
    width:"100%",
    borderCollapse:"collapse",
    marginTop:"15px"
  },

  th:{
    padding:"12px",
    background:"rgba(255,255,255,0.12)",
    textAlign:"left"
  },

  td:{
    padding:"12px",
    borderBottom:"1px solid rgba(255,255,255,0.12)"
  },

  viewBtn:{
    padding:"6px 14px",
    borderRadius:"6px",
    background:"#203a43",
    color:"#fff",
    border:"none",
    cursor:"pointer"
  }

};

export default Dashboard;