import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import Layout from "../components/Layout";

function Claims() {

  const navigate = useNavigate();

  const [claims, setClaims] = useState([]);
  const [search,setSearch] = useState("");
  const [statusFilter,setStatusFilter] = useState("All");
  const [selectedClaims,setSelectedClaims] = useState([]);

  // ✅ FETCH FROM BACKEND
  useEffect(() => {
    axios.get("http://localhost:30000/api/claims")
      .then((res) => {
        console.log("API DATA:", res.data);
        setClaims(res.data.data);
      })
      .catch((err) => {
        console.error("Error:", err);
      });
  }, []);

  const toggleSelect = (id) => {
    if(selectedClaims.includes(id)){
      setSelectedClaims(selectedClaims.filter(c=>c!==id));
    } else{
      setSelectedClaims([...selectedClaims,id]);
    }
  };

  const filteredClaims = claims.filter((c)=>{
    const customer = (c.userName || "").toLowerCase();
    const vehicle = (c.vehicle?.model || "").toLowerCase();
    const id = (c._id || "").toString();

    const matchesSearch =
      customer.includes(search.toLowerCase()) ||
      vehicle.includes(search.toLowerCase()) ||
      id.includes(search);

    const matchesStatus =
      statusFilter === "All" || c.status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  return (

    <Layout title="Claims">

      <div style={styles.content}>
        <div style={styles.container}>

          <h1 style={styles.heading}>Claims Management</h1>

          <div style={styles.filters}>

            <input
              type="text"
              placeholder="Search by Claim ID, Customer or Vehicle"
              value={search}
              onChange={(e)=>setSearch(e.target.value)}
              style={styles.search}
            />

            <select
              value={statusFilter}
              onChange={(e)=>setStatusFilter(e.target.value)}
              style={styles.select}
            >
              <option value="All">All Status</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>

          </div>

          <div style={styles.tableContainer}>

            <table style={styles.table}>

              <thead>
                <tr>
                  <th style={styles.th}></th>
                  <th style={styles.th}>Claim ID</th>
                  <th style={styles.th}>Customer</th>
                  <th style={styles.th}>Vehicle</th>
                  <th style={styles.th}>Status</th>
                  <th style={styles.th}>Estimate</th>
                  <th style={styles.th}>Action</th>
                </tr>
              </thead>

              <tbody>

                {filteredClaims.map((c)=>(

                  <tr
                    key={c._id}
                    style={styles.row}
                    onClick={()=>navigate(`/claims/${c._id}`)}
                    onMouseEnter={(e)=>e.currentTarget.style.background="rgba(255,255,255,0.08)"}
                    onMouseLeave={(e)=>e.currentTarget.style.background="transparent"}
                  >

                    <td style={styles.td}>
                      <input
                        type="checkbox"
                        checked={selectedClaims.includes(c._id)}
                        onClick={(e)=>e.stopPropagation()}
                        onChange={()=>toggleSelect(c._id)}
                      />
                    </td>

                    <td style={styles.td}>{c._id}</td>

                    <td style={styles.td}>
                      {c.userName || "N/A"}
                    </td>

                    <td style={styles.td}>
                      {c.vehicle?.make} {c.vehicle?.model}
                    </td>

                    <td style={styles.td}>
                      <span style={statusStyle(c.status || "pending")}>
                        {c.status || "pending"}
                      </span>
                    </td>

                    <td style={styles.td}>
                      Rs. {(c.estimatedAmount || 0).toLocaleString()}
                    </td>

                    <td style={styles.td}>
                      <button
                        style={styles.viewBtn}
                        onClick={(e)=>{
                          e.stopPropagation();
                          navigate(`/claims/${c._id}`);
                        }}
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

function statusStyle(status){
  return{
    padding:"6px 12px",
    borderRadius:"20px",
    fontSize:"12px",
    color:"#fff",
    background:
      status==="approved"
        ? "#27ae60"
        : status==="pending"
        ? "#f39c12"
        : "#e74c3c",
  };
}

const styles={
content:{
  padding:"30px",
  background:"linear-gradient(135deg,#0f2027,#203a43,#2c5364)",
  minHeight:"100vh"
},
container:{
  maxWidth:"1200px",
  margin:"0 auto",
  color:"#fff"
},
heading:{
  marginBottom:"24px",
  fontSize:"28px",
  fontWeight:"600"
},
filters:{
  display:"flex",
  gap:"16px",
  marginBottom:"20px"
},
search:{
  flex:2,
  padding:"12px 16px",
  borderRadius:"8px",
  border:"none"
},
select:{
  padding:"12px 16px",
  borderRadius:"8px",
  border:"none"
},
tableContainer:{
  background:"linear-gradient(135deg,#2a536b,#346c89)",
  padding:"22px",
  borderRadius:"16px"
},
table:{
  width:"100%",
  borderCollapse:"collapse"
},
th:{
  padding:"12px",
  textAlign:"left"
},
td:{
  padding:"14px",
  borderBottom:"1px solid rgba(255,255,255,0.12)"
},
row:{
  cursor:"pointer",
  transition:"background 0.2s"
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

export default Claims;