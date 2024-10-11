import { ethers } from 'hardhat'

async function main (): void {
  const name = 'HpcToken'
  const Token =
    await ethers.getContractFactory(name)
  const token =
    await Token.deploy()

  await token.waitForDeployment()
  console.log(`${name} deployed to ${await token.getAddress()}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
