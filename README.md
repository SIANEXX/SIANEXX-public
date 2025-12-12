# SIA Platform Smart Contracts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![BSC Mainnet](https://img.shields.io/badge/BSC-Mainnet-yellow.svg)](https://bscscan.com/address/0x052965eA4FE4e299594cd077D9a21c7808de5465)

Official smart contracts for SIA Platform on BNB Smart Chain.

## Overview

SIA Platform is a unified payment contract that manages on-chain operations for the SIA ecosystem, including:

- **Check-in System** - Daily check-in with rewards
- **Agent Creation** - Create AI agents on-chain
- **Alliance Creation** - Create alliances/guilds on-chain

## Features

- Dual payment support (BNB & USDT)
- Dynamic pricing via Chainlink Price Oracle
- Automatic refund of excess payment
- Two-step ownership transfer for security
- Contract pause functionality

## Contract Addresses

### BSC Mainnet (Chain ID: 56)

| Contract | Address |
|----------|---------|
| SIA_Platform | [`0x052965eA4FE4e299594cd077D9a21c7808de5465`](https://bscscan.com/address/0x052965eA4FE4e299594cd077D9a21c7808de5465) |
| USDT (BSC) | [`0x55d398326f99059fF775485246999027B3197955`](https://bscscan.com/token/0x55d398326f99059fF775485246999027B3197955) |
| Chainlink BNB/USD | [`0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE`](https://bscscan.com/address/0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE) |

## Contract Functions

### User Functions

#### Check-in

```solidity
// Check-in with BNB
function checkIn() external payable

// Check-in with USDT (requires prior approval)
function checkInUSDT() external
```

#### Agent Creation

```solidity
// Create agent with BNB
function agentCreate() external payable

// Create agent with USDT (requires prior approval)
function agentCreateUSDT() external
```

#### Alliance Creation

```solidity
// Create alliance with BNB
function allianceCreate() external payable

// Create alliance with USDT (requires prior approval)
function allianceCreateUSDT() external
```

### Query Functions

```solidity
// Get required BNB amount for check-in
function getCheckInAmount() public view returns (uint)

// Get required USDT amount for check-in
function getCheckInAmountUSDT() public view returns (uint)

// Get required BNB amount for agent creation
function getAgentCreateAmount() public view returns (uint)

// Get required USDT amount for agent creation
function getAgentCreateAmountUSDT() public view returns (uint)

// Get required BNB amount for alliance creation
function getAllianceCreateAmount() public view returns (uint)

// Get required USDT amount for alliance creation
function getAllianceCreateAmountUSDT() public view returns (uint)

// Check if contract is enabled
function getSwitch() external view returns (bool)

// Get USDT token address
function getUSDTAddress() external view returns (address)

// Get payment receiver address
function getReceiver() external view returns (address)
```

## Events

```solidity
event CheckedIn(address indexed account, uint amount, uint remains)
event CheckedInUSDT(address indexed account, uint amount)
event AgentCreated(address indexed account, uint amount, uint remains)
event AgentCreatedUSDT(address indexed account, uint amount)
event AllianceCreated(address indexed account, uint amount, uint remains)
event AllianceCreatedUSDT(address indexed account, uint amount)
```

## Usage Example

### Using Ethers.js v6

```javascript
import { ethers } from 'ethers';
import SIA_PLATFORM_ABI from './contracts/abis/SIA_Platform.json';

const CONTRACT_ADDRESS = '0x052965eA4FE4e299594cd077D9a21c7808de5465';

// Connect to BSC
const provider = new ethers.JsonRpcProvider('https://bsc-dataseed.binance.org/');
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

// Create contract instance
const contract = new ethers.Contract(CONTRACT_ADDRESS, SIA_PLATFORM_ABI, signer);

// Get check-in amount
const amount = await contract.getCheckInAmount();
console.log(`Check-in cost: ${ethers.formatEther(amount)} BNB`);

// Execute check-in
const tx = await contract.checkIn({ value: amount });
await tx.wait();
console.log('Check-in successful!');
```

### Using USDT

```javascript
import ERC20_ABI from './contracts/abis/ERC20.json';

const USDT_ADDRESS = '0x55d398326f99059fF775485246999027B3197955';
const usdt = new ethers.Contract(USDT_ADDRESS, ERC20_ABI, signer);

// Get required amount
const amount = await contract.getCheckInAmountUSDT();

// Approve USDT spending
const approveTx = await usdt.approve(CONTRACT_ADDRESS, amount);
await approveTx.wait();

// Execute check-in with USDT
const tx = await contract.checkInUSDT();
await tx.wait();
```

## Security

- Two-step ownership transfer prevents accidental ownership loss
- Contract can be paused by owner in case of emergency
- All payments are forwarded to a configurable receiver address
- Excess BNB payments are automatically refunded

## Dependencies

- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) - ERC20 interface
- [Chainlink](https://github.com/smartcontractkit/chainlink) - Price feed oracle

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
