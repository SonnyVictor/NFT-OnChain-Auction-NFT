// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // const nftContractFactory = await hre.ethers.getContractFactory("NPCnft");
  // const nftContract = await nftContractFactory.deploy();
  // await nftContract.deployed();

  // console.log("Contract deployed to:", nftContract.address);

  const auctionContractFactory = await hre.ethers.getContractFactory("Auction");
  const auctionContract = await auctionContractFactory.deploy(
    "0x85100173367853B94cB92A5CaDE7F9B5082DdEDE"
  );
  await auctionContract.deployed();

  console.log("Contract deployed to:", auctionContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
