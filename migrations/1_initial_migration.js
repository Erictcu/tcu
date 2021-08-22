/* global artifacts */
const Migrations = artifacts.require('Migrations')

module.exports = function (deployer) {
    if (deployer.network === 'mainnet') {
        return
    }
    if (deployer.network === 'ropsten') {
        return
    }
    if (deployer.network === 'server') {
        return
    }
    deployer.deploy(Migrations)
}
