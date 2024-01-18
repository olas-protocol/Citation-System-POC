import { SchemaEncoder } from "@ethereum-attestation-service/eas-sdk";

const offchain = await eas.getOffchain();

// Initialize SchemaEncoder with the schema string
const schemaEncoder = new SchemaEncoder("bytes32[] citationUID, bytes32 authorName, string articleTitle, bytes32 articleHash, string urlOfContent");
const encodedData = schemaEncoder.encodeData([
  { name: "citationUID", value: 1, type: "bytes32[]" },
  { name: "authorName", value: 1, type: "bytes32" },
  { name: "articleTitle", value: 1, type: "string" },
  { name: "articleHash", value: 1, type: "bytes32" },
  { name: "urlOfContent", value: 1, type: "string" },
]);

// Signer is an ethers.js Signer instance
const signer = new ethers.Wallet(privateKey, provider);

const offchainAttestation = await offchain.signOffchainAttestation(
  {
    recipient: "0xdd74500Da50db8B5A120310A00443C55b8Df3F10", //TEST WALLET ADDRESS
    // Unix timestamp of when attestation expires. (0 for no expiration)
    expirationTime: 0,
    // Unix timestamp of current time
    time: 1671219636,
    revocable: false, // Be aware that if your schema is not revocable, this MUST be false
    version: 1,
    nonce: 0,
    schema:
      "0x0f90dc33213e0876a9125c7534a806b6366907943cbabd19dd6a9df5784d1a7a",
    refUID:
      "0x0000000000000000000000000000000000000000000000000000000000000000",
    data: encodedData,
  },
  signer,
);
