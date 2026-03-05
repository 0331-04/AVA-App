import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Layout from "../components/Layout";

function Claims() {

  const navigate = useNavigate();

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

  const [search,setSearch] = useState("");
  const [statusFilter,setStatusFilter] = useState("All");

  const filteredClaims = claims.filter((c)=>{

    const matchesSearch =
      c.customer.toLowerCase().includes(search.toLowerCase()) ||
      c.vehicle.toLowerCase().includes(search.toLowerCase()) ||
      c.id.toString().includes(search);

    const matchesStatus =
      statusFilter === "All" || c.status === statusFilter;

    return matchesSearch && matchesStatus;

  });

  return (

    <Layout>

      <div style={styles.content}>
        <div style={styles.container}>

          <h1 style={styles.heading}>Claims</h1>

          {/* Filters */}

          <div style={styles.filters}>

            <input
              type="text"
              placeholder="Search by Claim ID, Customer or Vehicle"
              value={search}
              onChange={(e)=>setSearch(e.target.value)}
              style={styles.search}
              onMouseEnter={(e)=>e.target.style.boxShadow="0 0 0 2px #00e0ff"}
              onMouseLeave={(e)=>e.target.style.boxShadow="none"}
              onFocus={(e)=>e.target.style.boxShadow="0 0 0 2px #00e0ff"}
              onBlur={(e)=>e.target.style.boxShadow="none"}
            />

            <select
              value={statusFilter}
              onChange={(e)=>setStatusFilter(e.target.value)}
              style={styles.select}
            >
              <option value="All">All Status</option>
              <option value="Pending">Pending</option>
              <option value="Approved">Approved</option>
              <option value="Under Review">Under Review</option>
            </select>

          </div>

          {/* Claims Table */}

          <div style={styles.tableContainer}>

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

                {filteredClaims.length === 0 ? (

                  <tr>
                    <td colSpan="6" style={styles.empty}>
                      No claims found
                    </td>
                  </tr>

                ) : (

                  filteredClaims.map((c)=>(
                    <tr
                      key={c.id}
                      onMouseEnter={(e)=>e.currentTarget.style.background="rgba(255,255,255,0.08)"}
                      onMouseLeave={(e)=>e.currentTarget.style.background="transparent"}
                    >

                      <td style={styles.td}>{c.id}</td>

                      <td style={styles.td}>{c.customer}</td>

                      <td style={styles.td}>{c.vehicle}</td>

                      <td style={styles.td}>
                        <span
                          style={statusStyle(c.status)}
                          onMouseEnter={(e)=>e.target.style.opacity="0.85"}
                          onMouseLeave={(e)=>e.target.style.opacity="1"}
                        >
                          {c.status}
                        </span>
                      </td>

                      <td style={styles.td}>
                        Rs. {c.estimate.toLocaleString()}
                      </td>

                      <td style={styles.td}>
                        <button
                          style={styles.viewBtn}
                          onMouseEnter={(e)=>{
                            e.target.style.background="#00e0ff";
                            e.target.style.color="#000";
                            e.target.style.transform="translateY(-2px)";
                          }}
                          onMouseLeave={(e)=>{
                            e.target.style.background="#203a43";
                            e.target.style.color="#fff";
                            e.target.style.transform="translateY(0)";
                          }}
                          onClick={()=>navigate(`/claims/${c.id}`)}
                        >
                          View
                        </button>
                      </td>

                    </tr>
                  ))

                )}

              </tbody>

            </table>

          </div>

        </div>
      </div>

    </Layout>

  );
}

/* Status badge */

function statusStyle(status){

  return{
    padding:"6px 12px",
    borderRadius:"20px",
    fontSize:"12px",
    color:"#fff",
    background:
      status==="Approved"
        ? "#27ae60"
        : status==="Pending"
        ? "#f39c12"
        : "#2980b9",
    transition:"opacity 0.2s"
  };

}

/* Styles */

const styles={

  content:{
    padding:"30px",
    background:"linear-gradient(135deg,#0f2027,#203a43,#2c5364)",
    minHeight:"100vh"
  },

  container:{
    maxWidth:"1200px",
    margin:"0 auto"
  },

  heading:{
    color:"#fff",
    marginBottom:"24px",
    fontSize:"28px",
    fontWeight:"600"
  },

  filters:{
    display:"flex",
    gap:"16px",
    marginBottom:"22px"
  },

  search:{
    flex:1,
    padding:"12px 16px",
    borderRadius:"8px",
    border:"none",
    transition:"box-shadow 0.2s"
  },

  select:{
    padding:"12px 16px",
    borderRadius:"8px",
    border:"none"
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
    marginTop:"10px"
  },

  th:{
    padding:"14px",
    background:"rgba(255,255,255,0.12)",
    textAlign:"left"
  },

  td:{
    padding:"16px",
    borderBottom:"1px solid rgba(255,255,255,0.12)"
  },

  empty:{
    padding:"30px",
    textAlign:"center",
    color:"#e6f6ff"
  },

  viewBtn:{
    padding:"6px 14px",
    borderRadius:"6px",
    background:"#203a43",
    color:"#fff",
    border:"none",
    cursor:"pointer",
    transition:"all 0.2s ease"
  }

};

export default Claims;