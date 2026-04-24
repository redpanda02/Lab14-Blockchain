# Lab 14  — Token DApp

We are building, a simple token transfer DApp. 

To deploy to Sepolia frm hardhat you need two things: a RPC URL and some `testnet ETH`.

So do this first .

1. Get an RPC URL — create a free Infura or Alchemy account

- `Alchemy` — [https://www.alchemy.com/](https://www.alchemy.com/) → sign up → create an app on Ethereum > Sepolia → copy the HTTPS URL:
  `https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY`

- `Infura` — [app.infura.io](https://app.infura.io) 

You will store this in Hardhat's secret store (see Step 1), not in a plain file.

2. Get free Sepolia ETH

Paste your MetaMask address into a faucet:
- [sepoliafaucet.com](https://sepoliafaucet.com)
- [faucet.quicknode.com/ethereum/sepolia](https://faucet.quicknode.com/ethereum/sepolia)
- [cloud.google.com/application/web3/faucet/ethereum/sepolia](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

To get your MetaMask private key: click the three dots next to your account > Account Details > Export Private Key. You will need it in Step 1. Never commit it to Git.

## Step 1 — Hardhat 3 project setup

```bash
mkdir my-token && cd my-token
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox-viem
npx hardhat init   # choose TypeScript + viem when prompted
```

`Store your secrets` using Hardhat's built-in secret store (no `.env` needed):

```bash
npx hardhat vars set SEPOLIA_RPC_URL
# paste your Infura or Alchemy URL when prompted

npx hardhat vars set SEPOLIA_PRIVATE_KEY
# paste your MetaMask private key when prompted
```

Secrets are stored encrypted on your machine and never touch the repository.

`hardhat.config.ts` — use this exact config:

```typescript
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
    },
  },
  networks: {
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
});
```

## Step 2 — Smart contract

Your contract must follow this 3-layer architecture:

`contracts/IMyToken.sol` — interface (signatures and events only, no logic)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    function transfer(address to, uint256 amount) external;
    function getBalance(address user) external view returns (uint256);
}
```

`contracts/MyTokenBase.sol` — abstract contract (shared logic, fee left unimplemented)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./IMyToken.sol";

abstract contract MyTokenBase is IMyToken {
    mapping(address => uint256) public balances;

    function getBalance(address user) public view override returns (uint256) {
        return balances[user];
    }

    // Child contracts must decide how the fee is calculated.
    function _calculateFee(uint256 amount) internal virtual pure returns (uint256);

    function transfer(address to, uint256 amount) public override {
        uint256 fee = _calculateFee(amount);
        require(balances[msg.sender] >= amount + fee, "Insufficient balance");
        // TODO: deduct amount + fee from sender
        // TODO: add amount to recipient
        // TODO: emit Transfer event
    }
}
```

``contracts/MyToken.sol`` — your concrete contract (your group's design goes here)
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./MyTokenBase.sol";

contract MyToken is MyTokenBase {
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        balances[msg.sender] = initialSupply;
    }

    function _calculateFee(uint256 amount) internal pure override returns (uint256) {
        // TODO: implement the fee (1% of the amount or 2 or 3 ....)
    }
}
```

Compile and deploy:

```bash
npx hardhat compile
npx hardhat run scripts/deploy.ts --network sepolia
```
Copy the printed contract address — you will need it in the frontend.

## Step 3 — Frontend

Create a `frontend/index.html` (or React app) that:
- Connects to MetaMask using ethers.js v6
- Displays the connected wallet address and its token balance
- Has a form to enter a recipient address and amount, then calls `transfer`
- Shows the transaction status (pending / confirmed / failed)

Copy your contract ABI from `artifacts/contracts/MyToken.sol/MyToken.json` into the frontend.

Minimal ethers.js v6 snippet:
```js
import { ethers } from "https://cdn.jsdelivr.net/npm/ethers@6/dist/ethers.min.js";

await window.ethereum.request({ method: "eth_requestAccounts" });
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

const balance = await contract.getBalance(await signer.getAddress());
```

If MetaMask is not on Sepolia, prompt the user to switch:

```js
await window.ethereum.request({
  method: "wallet_switchEthereumChain",
  params: [{ chainId: "0xaa36a7" }], // Sepolia
});
```

## Part 2 Extensions
We will extend our dApp with some other features

### 1. Allowances

Instead of only allowing `msg.sender` to spend their own tokens, let a user authorize a third party to spend up to a certain amount on their behalf. This is the mechanism behind every DEX and DApp approval flow.

In Interface (`IMyToken.sol`)

- Declare an `Approval` event with three parameters: `owner`, `spender`, and `amount` (all indexed where it makes sense)
- Add an `approve(address spender, uint256 amount)` function signature
- Add an `allowance(address owner, address spender) returns (uint256)` view function signature
- Add a `transferFrom(address from, address to, uint256 amount)` function signature

in Abstract contract (`MyTokenBase.sol`)

- Add a nested mapping `allowances` that tracks how much each spender is authorized to use per owner: `mapping(address => mapping(address => uint256))`
- Implement `approve` — it should record that `msg.sender` authorizes `spender` up to `amount`, then emit `Approval`
- Implement `allowance` — a simple read of `allowances[owner][spender]`
- Implement `transferFrom`:
  - Check that `allowances[from][msg.sender]` covers `amount + fee`
  - Deduct `amount + fee` from `balances[from]`
  - Add `amount` to `balances[to]`
  - Reduce `allowances[from][msg.sender]` by `amount + fee`
  - Emit `Transfer`

on the Frontend

- Add an "Approve" form: the connected wallet picks a spender address and an amount, then calls `approve`
- Add a "Transfer From" form: the connected wallet moves tokens from another address to a recipient, calling `transferFrom`
- Test the full flow between two group members' wallets — one approves, the other spends

### 2. Pausable Transfers

The idea: the contract owner can freeze all transfers in an emergency. Any transfer attempted while paused reverts immediately.

in the Concrete contract (`MyToken.sol`)

- Add an `owner` address variable and set it to `msg.sender` in the constructor
- Add a `paused` boolean, defaulting to `false`
- Write an `onlyOwner` modifier that reverts if `msg.sender != owner`
- Write a `whenNotPaused` modifier that reverts if `paused == true`
- Add a `Paused(address by)` and an `Unpaused(address by)` event to your interface or contract
- Implement `pause()` — restricted to owner, sets `paused = true`, emits `Paused`
- Implement `unpause()` — restricted to owner, sets `paused = false`, emits `Unpaused`
- Apply `whenNotPaused` to your transfer logic — discuss with your group: do you override `transfer` in `MyToken`, or do you modify `MyTokenBase`? Write down your reasoning in the README

On the Frontend

- On wallet connect, check if `await contract.owner()` matches the connected address
- If it does, show a Pause / Unpause button (hidden for non-owners)
- Display the current paused state somewhere visible in the UI
- Test it: try sending a transfer while paused and confirm the UI shows a meaningful error, not a raw revert

## Contract verification

Verify the contract as well with Hardhat so we can see the contract's source code.


## Deliverables

| | |
|---|---|
| GitHub repo | Public, with commits from all group members |
| Contract address | Deployed on Sepolia, visible on [sepolia.etherscan.io](https://sepolia.etherscan.io) |
| Live DApp URL | Publicly accessible (Vercel / Netlify / GitHub Pages) |
| README | Token name,  contract address, DApp URL |