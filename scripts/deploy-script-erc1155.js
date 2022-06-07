const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

//run with this for testing: npx hardhat run scripts/deploy-script.js --network rinkeby || mainnet || poligonMumbai || matic

// We get the contract to deploy
  let deployment_base_uri = "ipfs://someipfsCIDherewouldbenice/"
  const basicERC1155Contract = await hre.ethers.getContractFactory("BasicERC1155");
  const basicERC1155 = await basicERC721Contract.deploy(deployment_base_uri);

  await basicERC1155.deployed();

  console.log("basicERC1155 deployed to:", basicERC1155.address);
  
  //Uncomment the command that applies
  // console.log(`See collection in Opensea: https://testnets.opensea.io/${basicERC1155.address}`)
  // console.log(`See collection in Opensea: https://opensea.io/${basicERC1155.address}`)

}


const runMain = async () => {
  try {
      await main();
      process.exit(0);
  } catch (error) {
      console.log(error);
      process.exit(1);
  }
};


runMain();
