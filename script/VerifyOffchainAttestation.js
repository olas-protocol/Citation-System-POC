import {
  Offchain,
  PartialTypedDataConfig,
  OffchainAttestationVersion,
} from "@ethereum-attestation-service/eas-sdk";

const attestation = {
  // your offchain attestation
  sig: {
    domain: {
      name: "EAS Attestation",
      version: "0.26",
      chainId: 1,
      verifyingContract: "0xA1207F3BBa224E2c9c3c6D5aF63D0eb1582Ce587",
    },
    primaryType: "Attest",
    types: {
      Attest: [],
    },
    signature: {
      r: "",
      s: "",
      v: 28,
    },
    uid: "0x5134f511e0533f997e569dac711952dde21daf14b316f3cce23835defc82c065",
    message: {
      version: 1,
      schema:
        "0x27d06e3659317e9a4f8154d1e849eb53d43d91fb4f219884d1684f86d797804a",
      refUID:
        "0x0000000000000000000000000000000000000000000000000000000000000000",
      time: 1671219600,
      expirationTime: 0,
      recipient: "0xFD50b031E778fAb33DfD2Fc3Ca66a1EeF0652165",
      attester: "0x1e3de6aE412cA218FD2ae3379750388D414532dc",
      revocable: true,
      data: "0x0000000000000000000000000000000000000000000000000000000000000000",
    },
  },
  signer: "0x1e3de6aE412cA218FD2ae3379750388D414532dc",
};

const EAS_CONFIG: PartialTypedDataConfig = {
  address: attestation.sig.domain.verifyingContract,
  version: attestation.sig.domain.version,
  chainId: BigInt(attestation.sig.domain.chainId),
};
const offchain = new Offchain(EAS_CONFIG, OffchainAttestationVersion);
const isValidAttestation = offchain.verifyOffchainAttestationSignature(
  attestation.signer,
  attestation.sig,
);
