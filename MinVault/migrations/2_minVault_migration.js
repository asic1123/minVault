const master = artifacts.require("masterWethMim")

module.exports = function (deployer) {
  deployer.deploy(master);
};
