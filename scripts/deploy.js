const { ethers } = require("hardhat");

async function main() {
     
    const hardwareAddress = "0xE15cDcFC1Ace34a561bFC5231DfA6FbF7390B589"

    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());


    // AccessControlToken deployment
    const AccessControlToken = await ethers.getContractFactory("AccessControlToken");
    // constructor( string memory name_, string memory symbol_, uint256 amount_)
    const AccessControlTokencontract = await AccessControlToken.deploy("Acces Control Token", "ACT", ethers.utils.parseEther("10000000000000"));

    console.log("AccesControlToken deploy success");


    // TokenVendorDeployment
    const TokenVendor = await ethers.getContractFactory("TokenVendor");
    // constructor(address _tokenAddress, uint256 _initialPrice);
    const TokenVendorcontract = await TokenVendor.deploy(AccessControlTokencontract.address);

    console.log("TokenVendor deploy success");


    // Fare1 deployment
    const Fare1 = await ethers.getContractFactory("Fare1");
    const Fare1contract = await Fare1.deploy();

    console.log("Fare1  deploy success");


    // Fare1 deployment
    const Fare2 = await ethers.getContractFactory("Fare2");
    const Fare2contract = await Fare2.deploy();

    console.log("Fare2  deploy success");


    // AccessControl deployment
    const AccessControl = await ethers.getContractFactory("AccessControl");
    // Adapt deployment to new contract, constructor( address hardwareAddress_, address tokenAddress_, bool onchainTime_) 
    const AccessControlcontract = await AccessControl.deploy(hardwareAddress,AccessControlTokencontract.address, true);

    console.log("AccessControl deploy success");

    console.log("AccessControlTokencontract Contract address:", AccessControlTokencontract.address);
    console.log("AccessControlcontract Contract address:", AccessControlcontract.address);
    console.log("TokenVendor Contract address:", TokenVendorcontract.address);
    console.log("Fare1 Contract: ", Fare1contract.address);
    console.log("Fare2 Contract: ", Fare2contract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });