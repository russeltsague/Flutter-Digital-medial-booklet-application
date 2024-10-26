require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
};


module.exports = {
  solidity: "0.8.0",
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/YOUR_INFURA_PROJECT_ID`, // Replace with your Infura project ID
      accounts: [`0x${YOUR_PRIVATE_KEY}`], // Replace with your wallet private key
    },
  },
};
