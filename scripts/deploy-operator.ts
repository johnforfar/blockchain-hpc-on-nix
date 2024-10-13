import { ethers, upgrades } from 'hardhat'

async function main (): void {
  const token_hpc = process.env.TOKEN_HPC
  const [owner] = await ethers.getSigners()
  if (!token_hpc) {
      throw new Error('TOKEN HPC is missing. Exiting.')
  }

  const HpcOperator = await ethers.getContractFactory('HpcOperator')
  const hpcOperator =
        await upgrades.deployProxy(
          HpcOperator, [
            token_hpc,
            owner.address
          ], {
            unsafeAllow: ['delegatecall']
          })

  await hpcOperator.waitForDeployment()
  console.log(`operator deployed to ${await hpcOperator.getAddress()}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
