// deploy upgradeable client

import { ethers, upgrades } from 'hardhat'
import { getConfig } from '../config'

const address = getConfig()
async function main (): void {
  const name = 'HpcExample'
  const contract = await ethers.getContractFactory(name)
  const inst = await upgrades.deployProxy(contract, [
    address.operator_hpc,
    address.jobid_hpc,
    '100000000000000000',
    address.token_hpc
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
