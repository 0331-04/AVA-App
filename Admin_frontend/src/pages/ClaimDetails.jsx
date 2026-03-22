import { useParams, useNavigate } from "react-router-dom";
import { useState } from "react";
import Layout from "../components/Layout";
import { useAuth } from "../context/AuthContext";


function ClaimDetails() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();

  const claim = {
    id,
    customer: "Isuru Fernando",
    vehicle: "Toyota Hilux",
    status: "Pending",
  };

  const [status, setStatus] = useState(claim.status);

  return (
    <Layout title={`Claim #${id}`}>

      <div style={styles.container}>
        <button onClick={() => navigate(-1)}>
          ← Back
        </button>

        <h1>Claim #{id}</h1>

        <p>Customer: {claim.customer}</p>
        <p>Vehicle: {claim.vehicle}</p>

        <p>
          Status:
          <span style={statusStyle(status)}>
            {status}
          </span>
        </p>

        {user?.role !== "viewer" && (
          <div>
            <button onClick={()=>setStatus("Approved")}>Approve</button>
            <button onClick={()=>setStatus("Rejected")}>Reject</button>
          </div>
        )}
      </div>

    </Layout>
  );
}

function statusStyle(status){
  return{
    marginLeft:"10px",
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
  };
}

const styles={
  container:{
    padding:"30px",
    color:"#fff",
    background:"#0f2027",
    minHeight:"100vh"
  }
};

export default ClaimDetails;