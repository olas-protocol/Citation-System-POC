import { EAS, SchemaEncoder } from "@ethereum-attestation-service/eas-sdk";
import { ethers } from "ethers";
import crypto from 'crypto';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
dotenv.config();

function hashArticleContent(articleContent) {
  const hash = crypto.createHash('sha256');
  hash.update(articleContent);
  return '0x' + hash.digest('hex');
}

const articleContent = "Gm is the new hello because hello is used by tradFi shills....";

const articleHash = hashArticleContent(articleContent);

const formattedArticleHash = ethers.utils.hexlify(ethers.utils.arrayify(articleHash)); // Convert hex string to bytes32

async function createAttestation() {
  const EASContractAddress = "0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
  const privateKey = process.env.PRIVATE_KEY;
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_PROVIDER);
  const signer = new ethers.Wallet(privateKey).connect(provider);
  
  
  const eas = new EAS(EASContractAddress);
  eas.connect(signer);
  
  // Initialize SchemaEncoder with the schema string
  const schemaEncoder = new SchemaEncoder("bytes32[] citationUID, bytes32 authorName, string articleTitle, bytes32 articleHash, string urlOfContent");
  const encodedData = schemaEncoder.encodeData([
    { name: "citationUID", value: [
      ethers.utils.formatBytes32String("exampleUID1"), 
      ethers.utils.formatBytes32String("exampleUID2")
    ], type: "bytes32[]" },
    { name: "authorName", value: ethers.utils.formatBytes32String("VitalikButerin"), type: "bytes32" },
    { name: "articleTitle", value: "Why Gm is the new Hello", type: "string" },
    { name: "articleHash", value: formattedArticleHash, type: "bytes32" },
    { name: "urlOfContent", value: "https://example.com/content", type: "string" },
  ]);
  
  const schemaUID = "0x0fcfaf1c07cd7f659bfb352c7032d20708707b781cac580fe42eb520a645f35f";

  try {
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
    console.log("Olas Attestation Hash:", encodedData);

   // Writing to a file for test purposes
   const __dirname = path.dirname(fileURLToPath(import.meta.url));
  const filePath = path.join(__dirname, 'attestations.txt');
  fs.appendFileSync(filePath, `New Attestation UID: ${newAttestationUID}\n`);
  console.log("AttestationUID saved to file.");

  } catch (error) {
    console.error('Error creating attestation:', error);
  }
}

createAttestation();



