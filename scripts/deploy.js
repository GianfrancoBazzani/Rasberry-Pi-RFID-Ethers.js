async function main() {

    const hardwareAddress = "0x69D7AE155A657EEC0CDB5D93FC7D2BFA2CBF6763"
    const ownerAddress = "0xC9B9DEFB7A520E6B50A2F9AB71EB5DAB3CE7DC79"

    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());
  
    const ControlAccess = await ethers.getContractFactory("ControlAccess");
    const contract = await ControlAccess.deploy(hardwareAddress,ownerAddress);
  
    console.log("Contract address:", contract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });