# forge-usd-priced-membership-nft

[![CI](https://github.com/Blockchains/forge-usd-priced-membership-nft/actions/workflows/ci.yml/badge.svg)](https://github.com/Blockchains/forge-usd-priced-membership-nft/actions/workflows/ci.yml) [![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Blockchains/forge-usd-priced-membership-nft?quickstart=1)

> **Idea:** An NFT membership collection with ERC-2981 royalties, role-based minting, a pause switch, and a paid mint priced in USD using a Chainlink ETH/USD price feed

Composed end to end by [blockchainlab-compose](https://github.com/Blockchains/blockchainlab-compose) (the Blockchain Lab `/forge` engine), with no hand edits:
capabilities detected (`price-oracle` (index-taxonomy), `nft` (index-taxonomy), `royalties` (index-taxonomy), `pausable` (keyword-rule), `access-control` (keyword-rule)) → archetype `nft` → components picked from [blockchainlab-index](https://github.com/Blockchains/blockchainlab-index) → exact source files (plus import closure) copied from the Blockchains forks at pinned commits → pragma check against solc 0.8.30 and licence check → generated glue, tests, deploy script and CI → `forge build && forge test` → repo created → CI.

## Features
- ERC-721 with max supply
- ERC-2981 royalties
- paid mint priced in USD via Chainlink feed (staleness-checked, refunds excess)
- pausable transfers
- role-based minting (AccessControl)

## Run
```bash
git clone https://github.com/Blockchains/forge-usd-priced-membership-nft && cd forge-usd-priced-membership-nft
forge test -vv                      # unit tests; set MAINNET_RPC_URL to also run live-chain fork tests
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --account <keystore> --broadcast
```
Or run the **Deploy (Sepolia)** workflow after adding `DEPLOYER_PRIVATE_KEY` and `SEPOLIA_RPC_URL` secrets.

## Components
| Capability | Component | Licence | How chosen |
|---|---|---|---|
| nft | [`ERC721`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/ERC721/ERC721.sol) | MIT | planner-selected |
| nft | [`IERC721`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/ERC721/IERC721.sol) | MIT | indexed |
| royalties | [`ERC2981`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/common/ERC2981.sol) | MIT | planner-selected |
| nft | [`ERC721Pausable`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/token/ERC721/extensions/ERC721Pausable.sol) | MIT | indexed |
| price-oracle | [`AggregatorV3Interface`](https://github.com/Blockchains/chainlink-evm/blob/d1ee27b0b5875adb8eca1e0da05926f7eb1f6e1f/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol) | MIT | planner-selected |
| access-control | [`AccessControl`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/access/AccessControl.sol) | MIT | indexed |
| access-control | [`IAccessControl`](https://github.com/Blockchains/openzeppelin-contracts/blob/cab19933c33c2ad1d4c7a84864a3601dddfd16f3/contracts/access/IAccessControl.sol) | MIT | indexed |

| Fork | Pinned | Upstream | Files copied |
|---|---|---|---|
| [Blockchains/chainlink-evm](https://github.com/Blockchains/chainlink-evm/tree/d1ee27b0b5875adb8eca1e0da05926f7eb1f6e1f) | d1ee27b0b5 | [smartcontractkit/chainlink-evm](https://github.com/smartcontractkit/chainlink-evm) | 1 |
| [Blockchains/forge-std](https://github.com/Blockchains/forge-std/tree/f3dae6e6ee381f25eb6a246f7da9b85c91a68219) | v1.17.0 | [foundry-rs/forge-std](https://github.com/foundry-rs/forge-std) | 20 |
| [Blockchains/openzeppelin-contracts](https://github.com/Blockchains/openzeppelin-contracts/tree/cab19933c33c2ad1d4c7a84864a3601dddfd16f3) | v5.7.0 | [OpenZeppelin/openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) | 21 |

Every copied file is unmodified and keeps its SPDX header; see [NOTICE](NOTICE). Machine-readable: [`plan.json`](plan.json), [`component-map.json`](component-map.json).

## Licence
MIT for the generated glue. All copied components are permissively licensed.

Not audited. Review before deploying with real value.
