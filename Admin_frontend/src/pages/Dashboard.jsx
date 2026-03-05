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
  const [range,setRange] = useState("Last 30 Days");

  const claims = [
    { id:101, customer:"John Silva", vehicle:"Toyota Corolla", status:"Pending", estimate:120000 },
    { id:102, customer:"Nimal Perera", vehicle:"Honda Civic", status:"Approved", estimate:85000 },
    { id:103, customer:"Kasun Fernando", vehicle:"Nissan X-Trail", status:"Under Review", estimate:150000 },
    { id:104, customer:"Amal Jayasinghe", vehicle:"Suzuki Alto", status:"Approved", estimate:45000 },
    { id:105, customer:"Sachini Peris", vehicle:"Toyota Aqua", status:"Pending", estimate:98000 },
    { id:106, customer:"Ruwan De Silva", vehicle:"Mitsubishi Montero", status:"Under Review", estimate:320000 },
    { id:107, customer:"Tharindu Lakmal", vehicle:"Honda Fit", status:"Approved", estimate:76000 },
    { id:108, customer:"Isuru Fernando", vehicle:"Toyota Hilux", status:"Pending", estimate:210000 },
    { id:109, customer:"Dinuka Wijesinghe", vehicle:"BMW 320i", status:"Under Review", estimate:480000 },
  ];

  /* Analytics */

  const avgClaim =
    Math.round(
      claims.reduce((sum,c)=>sum+c.estimate,0) / claims.length
    );

  const approvalRate =
    Math.round(
      (claims.filter(c=>c.status==="Approved").length / claims.length) * 100
    );

  const totalEstimate =
    claims.reduce((sum,c)=>sum+c.estimate,0);

  /* Chart Data */

  const claimsOverTime = [
    { month:"Jan", claims:4 },
    { month:"Feb", claims:6 },
    { month:"Mar", claims:3 },
    { month:"Apr", claims:8 },
    { month:"May", claims:5 },
  ];

  const vehicleClaims = [
    { vehicle:"Toyota Corolla", count:3 },
    { vehicle:"Honda Civic", count:2 },
    { vehicle:"Toyota Hilux", count:2 },
    { vehicle:"Suzuki Alto", count:1 },
  ];

  /* Activity Feed */

  const activities = [
    { text:"Claim #102 approved by Agent Silva", time:"5 min ago" },
    { text:"Claim #108 moved to review", time:"20 min ago" },
    { text:"Claim #110 submitted by customer", time:"1 hour ago" },
    { text:"Estimate updated for Claim #101", time:"2 hours ago" },
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
              onChange={(e)=>setRange(e.target.value)}
              style={styles.rangeSelect}
            >
              <option>Last 7 Days</option>
              <option>Last 30 Days</option>
              <option>This Month</option>
              <option>Last 6 Months</option>
            </select>
          </div>

          {/* Primary KPI */}

          <div style={styles.widgets}>
            <Widget title="Total Claims" value={claims.length} icon={<MdDescription/>}/>
            <Widget title="Pending Claims" value={claims.filter(c=>c.status==="Pending").length} icon={<MdHourglassTop/>}/>
            <Widget title="Approved Claims" value={claims.filter(c=>c.status==="Approved").length} icon={<MdCheckCircle/>}/>
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
              <h3>Claims Over Time</h3>

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

          {/* Activity Feed */}

          <div style={styles.activityCard}>
            <h3>Recent Activity</h3>

            {activities.map((a,i)=>(
              <div key={i} style={styles.activityItem}>
                <span>{a.text}</span>
                <span style={styles.activityTime}>{a.time}</span>
              </div>
            ))}

          </div>

        </div>
      </div>

    </Layout>

  );
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

  heading:{
    color:"#fff",
    fontSize:"28px",
    fontWeight:"600"
  },

  rangeSelect:{
    padding:"8px 14px",
    borderRadius:"8px",
    border:"none"
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
    background:"linear-gradient(135deg,#2b556e,#356b88)",
    padding:"24px",
    borderRadius:"16px",
    textAlign:"center",
    color:"#fff"
  },

  smallWidget:{
    background:"linear-gradient(135deg,#2b556e,#356b88)",
    padding:"16px",
    borderRadius:"14px",
    textAlign:"center",
    color:"#fff"
  },

  widgetHeader:{
    display:"flex",
    justifyContent:"center",
    gap:"8px"
  },

  widgetTitle:{
    fontSize:"16px"
  },

  widgetIcon:{
    fontSize:"22px"
  },

  widgetValue:{
    fontSize:"32px",
    fontWeight:"700"
  },

  smallWidgetValue:{
    fontSize:"22px",
    fontWeight:"700"
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
    color:"#fff"
  },

  activityCard:{
    background:"linear-gradient(135deg,#2a536b,#346c89)",
    padding:"22px",
    borderRadius:"16px",
    color:"#fff"
  },

  activityItem:{
    display:"flex",
    justifyContent:"space-between",
    padding:"10px 0",
    borderBottom:"1px solid rgba(255,255,255,0.1)"
  },

  activityTime:{
    opacity:0.7,
    fontSize:"12px"
  }

};

export default Dashboard;