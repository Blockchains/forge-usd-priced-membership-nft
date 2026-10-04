// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/// @title UsdPricedMembership
/// @notice Composed by Blockchain Lab Forge from OpenZeppelin Contracts and Chainlink (via the Blockchains forks).
contract UsdPricedMembership is ERC721, ERC2981, ERC721Pausable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public immutable maxSupply;
    uint256 public totalMinted;
    string private baseURI_;
    error SoldOut();
    AggregatorV3Interface public immutable priceFeed;
    /// @notice Mint price in USD with 18 decimals (e.g. 25e18 = $25).
    uint256 public mintPriceUsd;
    /// @notice Oracle answers older than this are rejected.
    uint256 public maxPriceAge;
    error StaleOrInvalidPrice(int256 answer, uint256 updatedAt);
    error InsufficientPayment(uint256 sent, uint256 required);
    event MintPriceUsdSet(uint256 priceUsd);

    constructor(address admin, uint256 maxSupply_, string memory baseURI, address feed, uint256 mintPriceUsd_, uint256 maxPriceAge_, address royaltyReceiver, uint96 royaltyBps)
        ERC721("UsdPricedMembership", "UPM")
    {
        maxSupply = maxSupply_;
        baseURI_ = baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        priceFeed = AggregatorV3Interface(feed);
        mintPriceUsd = mintPriceUsd_;
        maxPriceAge = maxPriceAge_;
        _setDefaultRoyalty(royaltyReceiver, royaltyBps);
    }

    function _mintNext(address to) internal returns (uint256 id) {
        if (totalMinted >= maxSupply) revert SoldOut();
        id = ++totalMinted;
        _safeMint(to, id);
    }

    /// @notice Free mint by an authorised minter (airdrops, comps).
    function mintTo(address to) external onlyRole(MINTER_ROLE) returns (uint256) {
        return _mintNext(to);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    function setBaseURI(string calldata u) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI_ = u;
    }

    /// @notice Current mint price in wei, from the Chainlink feed (USD per native token).
    function mintPriceWei() public view returns (uint256) {
        (, int256 answer,, uint256 updatedAt,) = priceFeed.latestRoundData();
        if (answer <= 0 || updatedAt == 0 || block.timestamp - updatedAt > maxPriceAge) revert StaleOrInvalidPrice(answer, updatedAt);
        return (mintPriceUsd * 10 ** priceFeed.decimals() + uint256(answer) - 1) / uint256(answer); // round up
    }

    /// @notice Public paid mint. Excess payment is refunded.
    function mint() external payable returns (uint256 id) {
        uint256 price = mintPriceWei();
        if (msg.value < price) revert InsufficientPayment(msg.value, price);
        id = _mintNext(msg.sender);
        if (msg.value > price) {
            (bool ok,) = msg.sender.call{value: msg.value - price}("");
            require(ok, "refund failed");
        }
    }

    function setMintPriceUsd(uint256 p) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintPriceUsd = p;
        emit MintPriceUsdSet(p);
    }

    function withdraw(address payable to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "withdraw failed");
    }

    function setDefaultRoyalty(address receiver, uint96 bps) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, bps);
    }

    function pause() external onlyRole(PAUSER_ROLE) { _pause(); }
    function unpause() external onlyRole(PAUSER_ROLE) { _unpause(); }

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC2981, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
