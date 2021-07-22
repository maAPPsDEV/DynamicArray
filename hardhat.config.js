require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-truffle5");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

// const INFURA_PROJECT_ID = "e83a710ee610460882fc25ae775ecbee";
// const fs = require("fs");
// const PRIVATE_KEY = fs.readFileSync(".secret").toString().trim();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  // networks: {
  //   hardhat: {},
  //   kovan: {
  //     url: `https://kovan.infura.io/v3/${INFURA_PROJECT_ID}`,
  //     accounts: [PRIVATE_KEY],
  //   },
  // },
};
