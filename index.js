import ethers from "ethers";
import ControlAccessArtifact from "./artifacts/contracts/ControlAccess.sol/ControlAccess.json";

const providerRPC = {
  goerli: {
    name: 'goerli',
    rpc: "https://eth-goerli.g.alchemy.com/v2/NLb92VZ1dlIIDe-CJYgImlKQ5hovum1Y", 
    chainId: 5,
  },
};

const provider = new ethers.providers.StaticJsonRpcProvider(
  providerRPC.goerli.rpc, 
  {
    chainId: providerRPC.goerli.chainId,
    name: providerRPC.goerli.name,
  }
);

const signer = provider.getSigner("0x69D7AE155A657EEC0CDB5D93FC7D2BFA2CBF6763");

console.log("Raspberry Pi RFID Ethers")


