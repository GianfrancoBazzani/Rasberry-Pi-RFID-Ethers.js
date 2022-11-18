require("@nomicfoundation/hardhat-toolbox");



const PRIVATE_KEY = "d1412699eed0b792691d17565fd7f87eb53c724410987a8556cfd3fe7ade0796"; //0xeCEC0b20371664d5CfC9cE4FD3fC91050d72954a
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


