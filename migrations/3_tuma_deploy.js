const TUMA = artifacts.require("TUMA");

const name = "Tuma Inc"
const symbol = "TUMA"

module.exports = function (deployer) {
  deployer.deploy(TUMA, name, symbol);
};
