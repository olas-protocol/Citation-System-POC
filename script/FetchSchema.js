import { SchemaRegistry } from "@ethereum-attestation-service/eas-sdk";
import { ethers } from "ethers";
import dotenv from "dotenv";
dotenv.config();

const schemaRegistryContractAddress =
  "0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0"; // Sepolia 0.26
const schemaRegistry = new SchemaRegistry(schemaRegistryContractAddress);

const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_PROVIDER);
const signer = new ethers.Wallet(privateKey).connect(provider);

schemaRegistry.connect(signer);

const schemaUID =
  "0xdd1e02d1485d7fcbd2a9c027f8d3bbf8f0cb25ab8aaecf1d6af950e16c0717d8";

const schemaRecord = await schemaRegistry.getSchema({ uid: schemaUID });

console.log(schemaRecord);

// // Example Output
// {
//   uid: '0xYourSchemaUID',
//   schema: 'bytes32 proposalId, bool vote',
//   resolver: '0xResolverAddress',
//   revocable: true
// }
