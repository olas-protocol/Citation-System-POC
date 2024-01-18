import { SchemaRegistry } from "@ethereum-attestation-service/eas-sdk";
import { ethers } from "ethers";
import dotenv from 'dotenv';
dotenv.config();


async function registerSchema() {
  const schemaRegistryContractAddress = "0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0";
  
  const privateKey = process.env.PRIVATE_KEY;
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_PROVIDER);
  const signer = new ethers.Wallet(privateKey).connect(provider);
  
  const schemaRegistry = new SchemaRegistry(schemaRegistryContractAddress);
  schemaRegistry.connect(signer);
  
  const schema = "bytes32[] citationUID, bytes32 authorName, string articleTitle, bytes32 articleHash, string urlOfContent";
  const resolverAddress = undefined; // Sepolia 0.26
  const revocable = false;
  
  try {
    const transaction = await schemaRegistry.register({
      schema,
      resolverAddress,
      revocable,
    });
    
    const schemaUID = await transaction.wait();
    console.log('Olas Publication Schema UID:', schemaUID);
  } catch (error) {
    console.error('Error registering schema:', error);
  }
}

registerSchema();