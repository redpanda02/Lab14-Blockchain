# Lab14-Blockchain: MyToken DApp

This project implements a custom ERC20-like token called MyToken with a 1% transfer fee, deployed on Ethereum. It includes smart contracts written in Solidity, a frontend DApp for interacting with the token, and uses Hardhat for development, testing, and deployment.

## Project Overview

This blockchain lab project demonstrates:

- **MyToken Smart Contract**: A custom token contract with transfer functionality and a 1% fee on transfers.
- **Frontend DApp**: A web application using ethers.js to connect to MetaMask, display wallet balance, and perform token transfers.
- **Hardhat Development Environment**: For compiling, testing, and deploying contracts.
- **Ignition Deployment**: For automated contract deployment.

### Key Features

- ERC20-like token with name, symbol, and balance tracking
- Transfer function with a 1% fee (burned on transfer)
- MetaMask integration for wallet connection
- Sepolia testnet support
- Simple, responsive UI for token management

## Prerequisites

- Node.js (v18 or higher)
- MetaMask browser extension
- Sepolia ETH for deployment and transactions (can be obtained from faucets)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/redpanda02/Lab14-Blockchain.git
cd Lab14-Blockchain
```

2. Install dependencies:
```bash
npm install
```

## Usage

### Compiling Contracts

```bash
npx hardhat compile
```

### Running Tests

Run all tests:
```bash
npx hardhat test
```

Run Solidity tests only:
```bash
npx hardhat test solidity
```

### Deploying Contracts

1. Create an Ignition module for MyToken deployment (see `ignition/modules/Counter.ts` as example).

2. Deploy to local network:
```bash
npx hardhat ignition deploy ignition/modules/MyToken.ts
```

3. Deploy to Sepolia testnet:
   - Set your private key:
     ```bash
     npx hardhat keystore set SEPOLIA_PRIVATE_KEY
     ```
   - Deploy:
     ```bash
     npx hardhat ignition deploy --network sepolia ignition/modules/MyToken.ts
     ```

### Running the Frontend

1. Update the contract address in `frontend/index.html` (line 69) with your deployed contract address.

2. Open `frontend/index.html` in a web browser.

3. Connect your MetaMask wallet and switch to Sepolia network.

4. View your token balance and transfer tokens to other addresses.

## Token Details

- **Token Name**: MyToken (MTK)
- **Contract Address**: 0xc47ff5152a8bd3b3415e86c654364a018b4fc31e
- **Live DApp URL**: [Host frontend on GitHub Pages/Netlify and update here]

## Deployment Instructions

1. Set up secrets:
   ```bash
   npx hardhat vars set SEPOLIA_RPC_URL  # Paste your Alchemy/Infura URL
   npx hardhat vars set SEPOLIA_PRIVATE_KEY  # Paste your MetaMask private key
   ```

2. Deploy to Sepolia:
   ```bash
   npx hardhat run scripts/deploy.ts --network sepolia
   ```
   Copy the deployed address and update `frontend/index.html` line 69 and this README.

3. Verify contract:
   ```bash
   npx hardhat verify --network sepolia <CONTRACT_ADDRESS> "MyToken" "MTK" "1000000000000000000000000"
   ```

4. Host frontend: Enable GitHub Pages for the `frontend` folder in repository settings, or upload to Netlify, and update the URL here.

## Project Structure

- `contracts/`: Solidity smart contracts
  - `MyToken.sol`: Main token contract
  - `MyTokenBase.sol`: Base contract with core functionality
  - `IMyToken.sol`: Token interface
- `frontend/`: Web frontend
  - `index.html`: Complete DApp interface
- `ignition/modules/`: Deployment scripts
- `test/`: Test files
- `scripts/`: Utility scripts

## Contract Details

- **MyToken**: Inherits from MyTokenBase, sets name, symbol, and initial supply
- **Transfer Fee**: 1% of transfer amount is deducted from sender's balance
- **Initial Supply**: Set during deployment
- **Decimals**: Not implemented (assumed 0 for simplicity)

## Development

This project uses Hardhat 3 Beta with viem for Ethereum interactions and Node.js native test runner.

For more information on Hardhat, visit [hardhat.org](https://hardhat.org).
