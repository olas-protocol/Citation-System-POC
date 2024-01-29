import { EAS, SchemaEncoder } from "@ethereum-attestation-service/eas-sdk";
import { ethers } from "ethers";
import crypto from "crypto";
import dotenv from "dotenv";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
dotenv.config();

function hashArticleContent(articleContent) {
  const hash = crypto.createHash("sha256");
  hash.update(articleContent);
  return "0x" + hash.digest("hex");
}

const articleContent =
  "Gm is the latest hello because hello is used by tradFi shills....";

const articleHash = hashArticleContent(articleContent);

const formattedArticleHash = ethers.utils.hexlify(
  ethers.utils.arrayify(articleHash),
); // Convert hex string to bytes32

async function createAttestation() {
  const EASContractAddress = "0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
  const privateKey = process.env.PRIVATE_KEY;
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.RPC_PROVIDER,
  );
  const signer = new ethers.Wallet(privateKey).connect(provider);

  const eas = new EAS(EASContractAddress);
  eas.connect(signer);

  // Initialize SchemaEncoder with the schema string
  const schemaEncoder = new SchemaEncoder(
    "bytes32[] citationUID, bytes32 authorName, string articleTitle, bytes32 articleHash, string urlOfContent",
  );
  const encodedData = schemaEncoder.encodeData([
    {
      name: "citationUID",
      value: ["0xc9e78daf135516338479fb3093e46083e545d19f327cda9df161fa8d1da325cf"],
      type: "bytes32[]",
    },
    {
      name: "authorName",
      value: ethers.utils.formatBytes32String("Author Name"),
      type: "bytes32",
    },
    {
      name: "articleTitle",
      value: "Sample Article Title",
      type: "string",
    },
    { name: "articleHash", value: ethers.utils.formatBytes32String("ARTICLE_HASH_1234"), type: "bytes32" },
    {
      name: "urlOfContent",
      value: "https://example.com/article",
      type: "string",
    },
  ]);

  const dynamicArrayOffset = "0x0000000000000000000000000000000000000000000000000000000000000020";
  let adjustedEncodedData = dynamicArrayOffset + encodedData.substring(2);

  const schemaUID =
    "0xdd1e02d1485d7fcbd2a9c027f8d3bbf8f0cb25ab8aaecf1d6af950e16c0717d8";

  // Construct the transaction with a specified gas limit
  const txOptions = {
    gasLimit: ethers.utils.hexlify(5000000), // Example gas limit, adjust based on your needs
  };

  try {
    const tx = await eas.attest(
      {
        schema: schemaUID,
        data: {
          recipient: "0xdd74500Da50db8B5A120310A00443C55b8Df3F10", //TEST WALLET ADDRESS
          expirationTime: 0,
          value: ethers.utils.parseEther("0.0001"),
          revocable: false, // Be aware that if your schema is not revocable, this MUST be false
          data: adjustedEncodedData,
        },
      },
      txOptions,
    );

    const newAttestationUID = await tx.wait();
    console.log("New Olas publication attestation UID:", newAttestationUID);
    console.log("Olas Attestation Hash:", encodedData);

    // Writing to a file for test purposes
    const __dirname = path.dirname(fileURLToPath(import.meta.url));
    const filePath = path.join(__dirname, "attestations.txt");
    fs.appendFileSync(filePath, `New Attestation UID: ${newAttestationUID}\n`);
    console.log("AttestationUID saved to file.");
  } catch (error) {
    console.error("Error creating attestation:", error);
  }
}

createAttestation();
