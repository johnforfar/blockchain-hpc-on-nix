// deploy upgradeable client

import { ethers, upgrades } from 'hardhat'

async function main (): void {
    const contractAddress = process.env.EXAMPLE_CONTRACT
    const name = 'HpcExample'
    const HpcExample = await ethers.getContractFactory(name)
    const hpcExample = HpcExample.attach(contractAddress)
    const address = await hpcExample.getToken()
    console.log(address)
    const tx = await hpcExample.changeToken(address)
    /*
    const tx = await hpcExample.doRequest(
	"test",
	"test",
	"test",
	"test",
	"test"
    ) */
    await tx.wait()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
