require("@nomicfoundation/hardhat-toolbox");



const PRIVATE_KEY = "a78a0c4a1ecff2b363c7733af0a9a4d42452471ee58c264035a2887a393f9e19"; //0xC9B9DEFB7A520E6B50A2F9AB71EB5DAB3CE7DC79
const GOERLI_ALCHEMY_API_KEY = "NLb92VZ1dlIIDe-CJYgImlKQ5hovum1Y"

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${GOERLI_ALCHEMY_API_KEY}`,
      accounts: [PRIVATE_KEY]
    },
    PolygonzkEVMTestnet: {
      url: `https://rpc.public.zkevm-test.net`,
      accounts: [PRIVATE_KEY],
      chainId: 1402
    }
  }
};


