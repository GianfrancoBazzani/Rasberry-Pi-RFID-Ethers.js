async function main() {
     
    const hardwareAddress = "0xE15cDcFC1Ace34a561bFC5231DfA6FbF7390B589"

    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());


    //AccessControlToken deployment
    const AccessControlToken = await ethers.getContractFactory("AccessControlToken");
    // constructor( string memory name_, string memory symbol_, uint256 amount_)
    const AccessControlTokencontract = await AccessControlToken.deploy("Standard Acces Control Token", "SACT", ethers.utils.parseEther("1000"));

    //AccessControl deployment
    const AccessControl = await ethers.getContractFactory("AccessControl");
    // Adapt deployment to new contract, constructor( address hardwareAddress_, address tokenAddress_, bool onchainTime_) 
    const AccessControlcontract = await AccessControl.deploy(hardwareAddress,AccessControlTokencontract.address, true);

    console.log("AccessControlTokencontract Contract address:", AccessControlTokencontract.address);
    console.log("AccessControlcontract Contract address:", AccessControlcontract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });