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

<!-- blocks:start -->
## Use as a building block

> **For AI agents and builders:** read [`AGENTS.md`](AGENTS.md) (setup, commands, structure, rules), [`llms.txt`](llms.txt) (doc map) and the machine-readable [`blocks.json`](blocks.json) ([schema](https://github.com/Blockchains/.github/blob/main/docs/BLOCKS-SCHEMA.md)). How all Blockchains blocks fit together: **[Build with Blocks](https://github.com/Blockchains/.github/blob/main/docs/BUILD-WITH-BLOCKS.md)** · org catalogue: [https://blockchains.github.io/blocks.json](https://blockchains.github.io/blocks.json).

**What it exports**

| Export | Type | Install / access |
|---|---|---|
| `UsdPricedMembership` | solidity | `forge install Blockchains/forge-usd-priced-membership-nft` |
| `script/Deploy.s.sol` | file | `forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --account <keystore> --broadcast` |
| `component-map.json, plan.json` | file | `provenance: capability → component → pinned fork commit` |

**Minimal example** (compiled and passed `forge test` on 2026-10-04 in a fresh Foundry project)

```solidity
// forge install Blockchains/forge-usd-priced-membership-nft Blockchains/openzeppelin-contracts@v5.7.0
// remappings.txt (lib/ in each forge-* repo holds only the files it needs, so map OZ to the full fork at the same commit):
//   @openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
//   @chainlink/contracts/src/=lib/forge-usd-priced-membership-nft/lib/chainlink-evm/contracts/src/
//   membership/=lib/forge-usd-priced-membership-nft/src/
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MembersOnly {                       // token gate on top of UsdPricedMembership
    IERC721 public immutable pass;
    mapping(address => string) public notes;
    error NotMember(address who);
    constructor(IERC721 pass_) { pass = pass_; }
    modifier onlyMembers() { if (pass.balanceOf(msg.sender) == 0) revert NotMember(msg.sender); _; }
    function post(string calldata note) external onlyMembers { notes[msg.sender] = note; }
}
// test: deploy UsdPricedMembership(admin, 100, "ipfs://base/", feed, 25e18, 1 hours, admin, 500),
// mint with value = nft.mintPriceWei(), then gate.post("gm") succeeds; before minting it reverts NotMember.
```

**Inputs → outputs**

- In: `constructor args` (Solidity) UsdPricedMembership(admin, maxSupply, baseURI, feed, mintPriceUsd (1e18 = $1), maxPriceAge, royaltyReceiver, royaltyBps)
- Out: `deployed contracts` (EVM); `events/errors` (ABI) see src/

**Composes with**

- [Blockchains/blockchainlab-compose](https://github.com/Blockchains/blockchainlab-compose): the composer that generated this repo
- [Blockchains/blockchainlab-sdk](https://github.com/Blockchains/blockchainlab-sdk): token-gated dApp data layer (Build with Blocks recipe 1)
- [Blockchains/forge-dao-governance-token](https://github.com/Blockchains/forge-dao-governance-token): add governance
- [Blockchains/blockchainlab-starters](https://github.com/Blockchains/blockchainlab-starters): chainlink-price-feed starter explains the oracle pattern

**Versioning & stability:** `reference`. Reference output of an automated composer; copied components are pinned to fork release tags (see NOTICE / component-map.json). Not audited. Treat as a starting point and review before deploying with value.
<!-- blocks:end -->

## Licence
MIT for the generated glue. All copied components are permissively licensed.

Not audited. Review before deploying with real value.

Composed by [blockchainlab-compose](https://github.com/Blockchains/blockchainlab-compose), the engine behind [blockchainlab.com/forge](https://blockchainlab.com/forge). Contracts only, no hosted site.

## Configuration

`script/Deploy.s.sol` reads (deployer = broadcaster = admin):

| Variable | Required | Default | Purpose |
|---|---|---|---|
| `PRICE_FEED` | yes | — | Chainlink ETH/USD feed (Sepolia: `0x694AA1769357215DE4FAC081bf1f309aDC325306`) |
| `MAX_SUPPLY` | no | 1000 | Max tokens |
| `BASE_URI` | no | `ipfs://REPLACE_ME/` | Token metadata base URI |
| `MINT_PRICE_USD` | no | 25e18 (US$25) | Mint price in USD, 18 decimals |
| `MAX_PRICE_AGE` | no | 1 day | Oracle staleness limit (seconds) |
| `ROYALTY_BPS` | no | 500 (5%) | ERC-2981 royalty |
| `MAINNET_RPC_URL` | no | — | Enables the live ETH/USD fork test |

The **Deploy (Sepolia)** workflow needs `DEPLOYER_PRIVATE_KEY` and `SEPOLIA_RPC_URL` repository secrets and stops with a clear error without them.

## Contributing

Issues and pull requests are welcome. Please read the [contributing guide](https://github.com/Blockchains/.github/blob/main/CONTRIBUTING.md), [code of conduct](https://github.com/Blockchains/.github/blob/main/CODE_OF_CONDUCT.md) and [security policy](https://github.com/Blockchains/.github/blob/main/SECURITY.md) first.

---
Built by Blockchain Lab — [blockchainlab.com](https://blockchainlab.com/?utm_source=github&utm_medium=readme&utm_campaign=forge-usd-priced-membership-nft)
