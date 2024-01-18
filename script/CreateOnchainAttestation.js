import { EAS, SchemaEncoder } from "@ethereum-attestation-service/eas-sdk";

const EASContractAddress = "0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
const eas = new EAS(EASContractAddress);
eas.connect(signer);

// Initialize SchemaEncoder with the schema string
const schemaEncoder = new SchemaEncoder("bytes32[] citationUID, bytes32 authorName, string articleTitle, bytes32 articleHash, string urlOfContent");
const encodedData = schemaEncoder.encodeData([
  { name: "citationUID", value: 1, type: "bytes32[]" },
  { name: "authorName", value: 1, type: "bytes32" },
  { name: "articleTitle", value: 1, type: "string" },
  { name: "articleHash", value: 1, type: "bytes32" },
  { name: "urlOfContent", value: 1, type: "string" },
]);

const schemaUID =
  "0x0f90dc33213e0876a9125c7534a806b6366907943cbabd19dd6a9df5784d1a7a";

const tx = await eas.attest({
  schema: schemaUID,
  data: {
    recipient: "0xdd74500Da50db8B5A120310A00443C55b8Df3F10",  //TEST WALLET ADDRESS
    expirationTime: 0,
    revocable: false, // Be aware that if your schema is not revocable, this MUST be false
    data: encodedData,
  },
});

const newAttestationUID = await tx.wait();

console.log("New Olas publication attestation UID:", newAttestationUID);
