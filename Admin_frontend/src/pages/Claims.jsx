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
  const [selectedClaims,setSelectedClaims] = useState([]);

  const toggleSelect = (id) => {

    if(selectedClaims.includes(id)){
      setSelectedClaims(selectedClaims.filter(c=>c!==id));
    } else{
      setSelectedClaims([...selectedClaims,id]);
    }

  };

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

          {/* Bulk actions */}

          {selectedClaims.length > 0 && (

            <div style={styles.bulkBar}>

              <span>{selectedClaims.length} selected</span>

              <div style={styles.bulkButtons}>

                <button style={styles.approveBtn}>
                  Approve Selected
                </button>

                <button style={styles.exportBtn}>
                  Export Selected
                </button>

              </div>

            </div>

          )}

          {/* Table */}

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

                  <tr key={c.id}>

                    <td style={styles.td}>

                      <input
                        type="checkbox"
                        checked={selectedClaims.includes(c.id)}
                        onChange={()=>toggleSelect(c.id)}
                      />

                    </td>

                    <td style={styles.td}>{c.id}</td>

                    <td style={styles.td}>{c.customer}</td>

                    <td style={styles.td}>{c.vehicle}</td>

                    <td style={styles.td}>
                      <span style={statusStyle(c.status)}>
                        {c.status}
                      </span>
                    </td>

                    <td style={styles.td}>
                      Rs. {c.estimate.toLocaleString()}
                    </td>

                    <td style={styles.td}>

                      <button
                        style={styles.viewBtn}
                        onClick={()=>navigate(`/claims/${c.id}`)}
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
      status==="Approved"
        ? "#27ae60"
        : status==="Pending"
        ? "#f39c12"
        : "#2980b9"

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
marginBottom:"20px"
},

search:{
flex:1,
padding:"12px 16px",
borderRadius:"8px",
border:"none"
},

select:{
padding:"12px 16px",
borderRadius:"8px",
border:"none"
},

bulkBar:{
display:"flex",
justifyContent:"space-between",
alignItems:"center",
background:"#203a43",
padding:"12px 18px",
borderRadius:"10px",
marginBottom:"16px",
color:"#fff"
},

bulkButtons:{
display:"flex",
gap:"10px"
},

approveBtn:{
background:"#27ae60",
border:"none",
color:"#fff",
padding:"8px 14px",
borderRadius:"6px",
cursor:"pointer"
},

exportBtn:{
background:"#00e0ff",
border:"none",
color:"#000",
padding:"8px 14px",
borderRadius:"6px",
cursor:"pointer"
},

tableContainer:{
background:"linear-gradient(135deg,#2a536b,#346c89)",
padding:"22px",
borderRadius:"16px",
color:"#fff"
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