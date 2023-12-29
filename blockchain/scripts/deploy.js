
async function main() {
    const Registry = await ethers.getContractFactory('Registry');
    console.log('Deploying Registry...');
    const registry = await Registry.deploy();
    await registry.waitForDeployment();
    console.log('Registry deployed to:', registry.target);
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.log(err);
        process.exit(1)
    })