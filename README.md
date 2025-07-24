# MoodFlip NFT 🎭

A fully on-chain NFT that changes its appearance based on the owner's mood! Built with Solidity and Foundry as part of advanced smart contract development.

## 🌟 Features

- **Dynamic NFT**: Token images change between happy and sad states
- **100% On-Chain**: All metadata and SVG images stored on-chain
- **ERC721 Compliant**: Full standard compliance with proper authorization
- **Mood Flipping**: Token owners and approved operators can change mood
- **Gas Optimized**: Efficient storage and operations

## 🛠️ Technologies Used

- **Solidity ^0.8.20**: Smart contract language
- **Foundry**: Development framework and testing
- **OpenZeppelin**: Battle-tested contract libraries
- **Base64 Encoding**: On-chain SVG storage
- **Foundry DevOps**: Deployment automation

## 📊 Test Coverage

- **100% Line Coverage**
- **100% Branch Coverage** 
- **100% Function Coverage**
- **28 Comprehensive Tests** including edge cases

## 🚀 Quick Start

### Prerequisites
- [Foundry](https://getfoundry.sh/)
- Git

### Installation
```bash
git clone https://github.com/Dakthehack/MoodFlipNft.git
cd MoodFlipNft
forge install
```

### Testing
```bash
# Run all tests
forge test

# Check coverage
forge coverage

# Run specific test
forge test --match-test testFlipMood
```

### Deployment
```bash
# Deploy to local network
forge script script/DeployMoodNft.s.sol

# Deploy to testnet (requires .env setup)
forge script script/DeployMoodNft.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## 🎨 NFT States

### Happy State 😊
- Yellow background
- Smiling expression
- Upward curved mouth

### Sad State 😢  
- Blue background
- Frowning expression
- Downward curved mouth

## 🔧 Contract Functions

### Core Functions
- `mintNft()`: Mint a new MoodNFT (starts happy)
- `flipMood(uint256 tokenId)`: Toggle between happy/sad states
- `tokenURI(uint256 tokenId)`: Get fully on-chain metadata

### Authorization
- Token owner can flip mood
- Approved addresses can flip mood
- Operators (via `setApprovalForAll`) can flip mood

## 🧪 Testing Strategy

- **Unit Tests**: Individual function testing
- **Integration Tests**: Cross-contract interactions  
- **Advanced Tests**: Gas optimization and edge cases
- **Fuzz Testing**: Random input validation

## 🏗️ Architecture

```
src/
├── MoodNft.sol          # Main NFT contract
├── BasicNft.sol         # Simple NFT implementation
script/
├── DeployMoodNft.s.sol  # Deployment script
├── DeployBasicNft.s.sol # Basic NFT deployment
└── Interactions.s.sol   # Interaction examples
test/
├── unit/                # Unit tests
├── integration/         # Integration tests
└── DeployMoodNftTest.t.sol # Deployment tests
```

## 📈 Gas Optimization

- Efficient storage patterns
- Minimal external calls
- Optimized loops and conditionals
- State variable packing

## 🔒 Security Features

- Proper access control
- Input validation
- Reentrancy protection (via OpenZeppelin)
- Integer overflow protection (Solidity ^0.8.0)

## 🚦 Deployment Networks

- ✅ Local Anvil
- ✅ Sepolia Testnet
- ⏳ Ethereum Mainnet (planned)

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 🎓 Learning Journey

This project demonstrates:
- Advanced Solidity patterns
- Comprehensive testing strategies
- Professional development workflows
- Smart contract security best practices

---

*Built with ❤️ using Foundry and OpenZeppelin*