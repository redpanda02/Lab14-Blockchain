import hre from "hardhat";

async function main() {
  const connection = await hre.network.connect();
  const token = await connection.viem.deployContract("MyToken", [
    "MyToken",
    "MTK",
    1000000n,
  ]);

  console.log(`MyToken deployed to: ${token.address}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
