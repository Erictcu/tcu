const path = require('path')
const fs = require('fs')
const genContract = require('circomlib/src/mimcsponge_gencontract.js')

const outputPath = path.join(__dirname, 'build', 'Hasher.json')

function main() {
  const contract = {
    contractName: 'Hasher',
    abi: genContract.abi,
    bytecode: genContract.createCode('mimcsponge', 220)
  }

  fs.writeFileSync(outputPath, JSON.stringify(contract))
}

main()
