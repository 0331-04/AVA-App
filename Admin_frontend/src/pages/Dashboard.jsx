import { useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import axios from "axios";
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

/* Animated Counter */
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

/* KPI Widget */
function Widget({ title, value, icon, size = "large" }) {
  const isSmall = size === "small";

  return (
    <div style={isSmall ? styles.smallWidget : styles.widget}>
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

  const [claims, setClaims] = useState([]);

  /* 🔥 FETCH REAL DATA */
  useEffect(() => {
    axios.get("http://localhost:30000/api/claims")
      .then(res => {
        setClaims(res.data.data || []);
      })
      .catch(err => console.error(err));
  }, []);

  /* 🔥 KPI CALCULATIONS */
  const totalClaims = claims.length;

  const pendingClaims = claims.filter(c => c.status === "pending").length;

  const approvedClaims = claims.filter(c => c.status === "approved").length;

  const totalEstimate = claims.reduce(
    (sum, c) => sum + (c.estimatedAmount || 0),
    0
  );

  const avgClaim = totalClaims
    ? Math.round(totalEstimate / totalClaims)
    : 0;

  const approvalRate = totalClaims
    ? Math.round((approvedClaims / totalClaims) * 100)
    : 0;

  /* 🔥 CHART DATA (DYNAMIC) */
  const claimsOverTime = claims.map((c, i) => ({
    month: `#${i + 1}`,
    claims: 1
  }));

  const vehicleMap = {};
  claims.forEach(c => {
    const v = c.vehicle?.model || "Unknown";
    vehicleMap[v] = (vehicleMap[v] || 0) + 1;
  });

  const vehicleClaims = Object.keys(vehicleMap).map(v => ({
    vehicle: v,
    count: vehicleMap[v]
  }));

  /* 🔥 RECENT ACTIVITY (AUTO) */
  const activities = claims.slice(0, 5).map(c => ({
    text: `New claim from ${c.userName}`,
    time: new Date(c.submittedAt).toLocaleString()
  }));

  return (
    <Layout title="Dashboard">

      <div style={styles.content}>
        <div style={styles.container}>

          <div style={styles.header}>
            <h1 style={styles.heading}>Admin Dashboard</h1>

            <select
              value={range}
              onChange={(e)=>setRange(e.target.value)}
              style={styles.rangeSelect}
            >
              <option>Last 7 Days</option>
              <option>Last 30 Days</option>
              <option>This Month</option>
              <option>Last 6 Months</option>
            </select>
          </div>

          {/* KPI */}
          <div style={styles.widgets}>
            <Widget title="Total Claims" value={totalClaims} icon={<MdDescription/>}/>
            <Widget title="Pending Claims" value={pendingClaims} icon={<MdHourglassTop/>}/>
            <Widget title="Approved Claims" value={approvedClaims} icon={<MdCheckCircle/>}/>
          </div>

          {/* Secondary KPI */}
          <div style={styles.secondaryWidgets}>
            <Widget title="Avg Claim Value" value={avgClaim} icon={<MdTrendingUp/>} size="small"/>
            <Widget title="Approval Rate (%)" value={approvalRate} icon={<MdTaskAlt/>} size="small"/>
            <Widget title="Total Estimate" value={totalEstimate} icon={<MdAttachMoney/>} size="small"/>
          </div>

          {/* Charts */}
          <div style={styles.chartRow}>
            <div style={styles.chartCard}>
              <h3>Claims (Recent)</h3>
              <ResponsiveContainer width="100%" height={260}>
                <LineChart data={claimsOverTime}>
                  <CartesianGrid stroke="rgba(255,255,255,0.1)" />
                  <XAxis dataKey="month" stroke="#e6f6ff"/>
                  <YAxis stroke="#e6f6ff"/>
                  <Tooltip/>
                  <Line type="monotone" dataKey="claims" stroke="#00e0ff" strokeWidth={3}/>
                </LineChart>
              </ResponsiveContainer>
            </div>

            <div style={styles.chartCard}>
              <h3>Claims by Vehicle</h3>
              <ResponsiveContainer width="100%" height={260}>
                <BarChart data={vehicleClaims} layout="vertical">
                  <CartesianGrid stroke="rgba(255,255,255,0.1)" />
                  <XAxis type="number" stroke="#e6f6ff"/>
                  <YAxis dataKey="vehicle" type="category" stroke="#e6f6ff"/>
                  <Tooltip/>
                  <Bar dataKey="count" fill="#00e0ff" radius={[0,6,6,0]}/>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Activity */}
          <div style={styles.activityCard}>
            <h3>Recent Activity</h3>
            {activities.map((a,i)=>(
              <div key={i} style={styles.activityItem}>
                <span>{a.text}</span>
                <span style={styles.activityTime}>{a.time}</span>
              </div>
            ))}
          </div>

          {/* Recent Claims */}
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
                  <tr key={c._id} style={styles.row}>
                    <td style={styles.td}>{c._id}</td>
                    <td style={styles.td}>{c.userName}</td>
                    <td style={styles.td}>{c.vehicle?.model}</td>

                    <td style={styles.td}>
                      <span style={statusStyle(c.status)}>
                        {c.status}
                      </span>
                    </td>

                    <td style={styles.td}>
                      Rs. {(c.estimatedAmount || 0).toLocaleString()}
                    </td>

                    <td style={styles.td}>
                      <button
                        style={styles.viewBtn}
                        onClick={() => navigate(`/claims/${c._id}`)}
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
      status === "approved"
        ? "#27ae60"
        : status === "pending"
        ? "#f39c12"
        : "#2980b9",
  };
}

const styles = {
  content:{padding:"30px",background:"linear-gradient(135deg,#0f2027,#203a43,#2c5364)",minHeight:"100vh"},
  container:{maxWidth:"1200px",margin:"0 auto"},
  header:{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:"24px"},
  heading:{color:"#fff",fontSize:"28px",fontWeight:"600"},
  rangeSelect:{padding:"8px 14px",borderRadius:"8px",border:"none"},
  widgets:{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(240px,1fr))",gap:"20px",marginBottom:"20px"},
  secondaryWidgets:{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(200px,1fr))",gap:"16px",marginBottom:"30px"},
  widget:{background:"linear-gradient(135deg,#2b556e,#356b88)",padding:"26px",borderRadius:"16px",textAlign:"center",color:"#fff"},
  smallWidget:{background:"linear-gradient(135deg,#2b556e,#356b88)",padding:"18px",borderRadius:"14px",textAlign:"center",color:"#fff"},
  widgetHeader:{display:"flex",flexDirection:"column",alignItems:"center",gap:"6px"},
  widgetTitle:{fontSize:"20px",fontWeight:"600",color:"#e6f6ff"},
  widgetIcon:{fontSize:"26px"},
  widgetValue:{fontSize:"40px",fontWeight:"700",marginTop:"10px"},
  smallWidgetValue:{fontSize:"26px",fontWeight:"600"},
  chartRow:{display:"grid",gridTemplateColumns:"1fr 1fr",gap:"20px",marginBottom:"30px"},
  chartCard:{background:"linear-gradient(135deg,#2a536b,#346c89)",padding:"22px",borderRadius:"16px",color:"#fff"},
  activityCard:{background:"linear-gradient(135deg,#2a536b,#346c89)",padding:"22px",borderRadius:"16px",color:"#fff",marginBottom:"30px"},
  activityItem:{display:"flex",justifyContent:"space-between",padding:"10px 0",borderBottom:"1px solid rgba(255,255,255,0.1)"},
  activityTime:{opacity:0.7,fontSize:"12px"},
  tableContainer:{background:"linear-gradient(135deg,#2a536b,#346c89)",padding:"22px",borderRadius:"16px",color:"#fff"},
  table:{width:"100%",borderCollapse:"collapse"},
  th:{padding:"12px",textAlign:"left"},
  td:{padding:"12px"},
  row:{transition:"background 0.2s ease"},
  viewBtn:{padding:"6px 14px",borderRadius:"6px",background:"#203a43",color:"#fff",border:"none",cursor:"pointer"}
};

export default Dashboard;