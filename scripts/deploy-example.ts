// deploy upgradeable client

import { ethers, upgrades } from 'hardhat'

async function main (): void {
  const token_hpc = process.env.TOKEN_HPC
  const jobid_hpc = process.env.JOBID_HPC
  const operator_hpc = process.env.OPERATOR_HPC
  const name = 'HpcExample'
  const contract = await ethers.getContractFactory(name)
  const inst = await upgrades.deployProxy(contract, [
    operator_hpc,
    jobid_hpc,
    '100000000000000000',
    token_hpc
  ])

  await inst.waitForDeployment()
  console.log(`${name} deployed to ${await inst.getAddress()}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
