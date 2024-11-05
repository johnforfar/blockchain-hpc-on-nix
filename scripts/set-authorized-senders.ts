// deploy upgradeable client

import { ethers, upgrades } from 'hardhat'

async function main (): void {
    const OPERATOR_HPC = process.env.OPERATOR_HPC
    const NODE_ETH_ADDRESS = process.env.NODE_ETH_ADDRESS
    const name = 'HpcOperator'
    const HpcOperator = await ethers.getContractFactory(name)
    const hpcOperator = HpcOperator.attach(OPERATOR_HPC)
    const tx = await hpcOperator.setAuthorizedSenders([ NODE_ETH_ADDRESS ])
    await tx.wait()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
