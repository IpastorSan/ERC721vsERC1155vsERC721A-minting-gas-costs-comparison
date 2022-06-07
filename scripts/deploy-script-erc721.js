const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {

//run with this for testing: npx hardhat run scripts/deploy-script.js --network rinkeby || mainnet || poligonMumbai || matic

// We get the contract to deploy
  let deployment_base_uri = "ipfs://someipfsCIDherewouldbenice/"
  const basicERC721Contract = await hre.ethers.getContractFactory("BasicERC721");
  const basicERC721 = await basicERC721Contract.deploy(deployment_base_uri);

  await basicERC721.deployed();

  console.log("basicERC721 deployed to:", basicERC721.address);
  
  //Uncomment the command that applies
  // console.log(`See collection in Opensea: https://testnets.opensea.io/${basicERC721.address}`)
  // console.log(`See collection in Opensea: https://opensea.io/${basicERC721.address}`)

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
