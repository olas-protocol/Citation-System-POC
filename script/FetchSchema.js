import { SchemaRegistry } from "@ethereum-attestation-service/eas-sdk";

const schemaRegistryContractAddress =
  "0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0"; // Sepolia 0.26
const schemaRegistry = new SchemaRegistry(schemaRegistryContractAddress);
schemaRegistry.connect(provider);

const schemaUID = "0x0f90dc33213e0876a9125c7534a806b6366907943cbabd19dd6a9df5784d1a7a";

const schemaRecord = await schemaRegistry.getSchema({ uid: schemaUID });

console.log(schemaRecord);

// // Example Output
// {
//   uid: '0xYourSchemaUID',
//   schema: 'bytes32 proposalId, bool vote',
//   resolver: '0xResolverAddress',
//   revocable: true
// }
