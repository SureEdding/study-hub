// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
const dotenv = require("dotenv")
dotenv.config()

const { INFURA_KEY, PRIVATE_KEY } = process.env;

const ROPSTEN_API_URL = "https://ropsten.infura.io/v3/"+INFURA_KEY
const RINKEBY_API_URL = "https://rinkeby.infura.io/v3/"+INFURA_KEY

module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "ropsten",
  networks: {
     hardhat: {},
     ropsten: {
        url: ROPSTEN_API_URL,
        accounts: [`0x${PRIVATE_KEY}`],
        gas: 5100000,
        gasPrice: 8000000000
     },
     rinkeby: {
        url: RINKEBY_API_URL,
        accounts: [`0x${PRIVATE_KEY}`],
        gas: 5100000,
        gasPrice: 8000000000
     }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      ropsten: "9EXII44HH1AAWE7WEKH2FUX6R1IRF7Q3AE",
      rinkeby: "9EXII44HH1AAWE7WEKH2FUX6R1IRF7Q3AE"
    }
  }
};
