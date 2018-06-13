const PVTSD = artifacts.require("./PVTSD.sol");
const PRETSD = artifacts.require("./PRETSD.sol");
const TSD = artifacts.require("./TSD.sol");

module.exports = function(deployer, network, accounts) {
  const exchangeRate = 50000;
  const pvtSaleTokenWallet = accounts[4]
  const preSaleTokenWallet = accounts[5]
  const foundersAndAdvisors = accounts[6]
  const bountyCommunityIncentives = accounts[7]
  const liquidityProgram = accounts[8]
  deployer.deploy(PVTSD, exchangeRate);
  deployer.deploy(PRETSD, exchangeRate);
  deployer.deploy(
    TSD,
    exchangeRate,
    pvtSaleTokenWallet,
    preSaleTokenWallet,
    foundersAndAdvisors,
    bountyCommunityIncentives,
    liquidityProgram
  );
};
