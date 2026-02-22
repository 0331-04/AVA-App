import { useParams } from "react-router-dom";

function ClaimDetails() {
  const { id } = useParams();

  return (
    <div style={{ padding: "30px" }}>
      <h2>Claim Details</h2>
      <p>Claim ID: {id}</p>
    </div>
  );
}

export default ClaimDetails;