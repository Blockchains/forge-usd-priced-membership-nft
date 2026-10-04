// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UsdPricedMembership.sol";
import "./utils/FixedPriceAggregator.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UsdPricedMembershipTest is Test {
    UsdPricedMembership nft;
    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    uint256 constant MAX = 3;
    FixedPriceAggregator feed;

    function setUp() public {
        vm.warp(1_700_000_000);
        feed = new FixedPriceAggregator(2500e8); // $2,500 per ETH
        nft = new UsdPricedMembership(admin, MAX, "ipfs://base/", address(feed), 25e18, 1 hours, admin, 500);
    }

    function test_minterMintsAndTokenURI() public {
        vm.prank(admin);
        uint256 id = nft.mintTo(alice);
        assertEq(id, 1);
        assertEq(nft.ownerOf(1), alice);
        assertEq(nft.tokenURI(1), "ipfs://base/1");
    }

    function test_onlyMinter() public {
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, alice, nft.MINTER_ROLE()));
        vm.prank(alice);
        nft.mintTo(alice);
    }

    function test_maxSupply() public {
        vm.startPrank(admin);
        for (uint256 i; i < MAX; i++) nft.mintTo(alice);
        vm.expectRevert(UsdPricedMembership.SoldOut.selector);
        nft.mintTo(alice);
        vm.stopPrank();
    }

    function test_supportsInterfaces() public view {
        assertTrue(nft.supportsInterface(type(IERC721).interfaceId));
        assertTrue(nft.supportsInterface(0x2a55205a)); // ERC-2981
    }

    function test_royaltyInfo() public view {
        (address r, uint256 amt) = nft.royaltyInfo(1, 10_000);
        assertEq(r, admin);
        assertEq(amt, 500); // 5%
    }

    function test_priceFromFeed() public view {
        // $25 at $2,500/ETH = 0.01 ETH
        assertEq(nft.mintPriceWei(), 0.01 ether);
    }

    function test_paidMintRefundsExcess() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        nft.mint{value: 0.05 ether}();
        assertEq(nft.ownerOf(1), alice);
        assertEq(alice.balance, 1 ether - 0.01 ether);
        assertEq(address(nft).balance, 0.01 ether);
        uint256 before = admin.balance;
        vm.prank(admin);
        nft.withdraw(payable(admin));
        assertEq(admin.balance - before, 0.01 ether);
    }

    function test_underpaymentReverts() public {
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(UsdPricedMembership.InsufficientPayment.selector, 0.009 ether, 0.01 ether));
        nft.mint{value: 0.009 ether}();
    }

    function test_staleOracleBlocksPaidMint() public {
        feed.set(2500e8, block.timestamp - 2 hours);
        vm.expectRevert();
        nft.mintPriceWei();
        feed.set(0, block.timestamp);
        vm.expectRevert();
        nft.mintPriceWei();
    }

    /// Reads the live Chainlink ETH/USD feed on an Ethereum mainnet fork when MAINNET_RPC_URL is set.
    function test_fork_liveChainlinkPrice() public {
        string memory rpc = vm.envOr("MAINNET_RPC_URL", string(""));
        if (bytes(rpc).length == 0) { vm.skip(true); return; }
        vm.createSelectFork(rpc);
        UsdPricedMembership live = new UsdPricedMembership(admin, MAX, "ipfs://base/", address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419), 25e18, 1 days, admin, 500);
        uint256 p = live.mintPriceWei();
        assertGt(p, 0.0005 ether); // $25 is more than 0.0005 ETH unless ETH > $50k
        assertLt(p, 1 ether);
    }

    function test_pauseBlocksTransfers() public {
        vm.prank(admin);
        nft.mintTo(alice);
        vm.prank(admin);
        nft.pause();
        vm.prank(alice);
        vm.expectRevert();
        nft.transferFrom(alice, admin, 1);
        vm.prank(admin);
        nft.unpause();
        vm.prank(alice);
        nft.transferFrom(alice, admin, 1);
        assertEq(nft.ownerOf(1), admin);
    }
}
