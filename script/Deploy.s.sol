// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/UsdPricedMembership.sol";

/// PRICE_FEED=0x694AA1769357215DE4FAC081bf1f309aDC325306 forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --account <keystore> --broadcast
contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        address admin = msg.sender;
        UsdPricedMembership c = new UsdPricedMembership(
            admin,
            vm.envOr("MAX_SUPPLY", uint256(1000)),
            vm.envOr("BASE_URI", string("ipfs://REPLACE_ME/")),
            vm.envAddress("PRICE_FEED") /* Sepolia ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306 */,
            vm.envOr("MINT_PRICE_USD", uint256(25e18)),
            vm.envOr("MAX_PRICE_AGE", uint256(1 days)),
            admin,
            uint96(vm.envOr("ROYALTY_BPS", uint256(500)))
        );
        console2.log("UsdPricedMembership", address(c));
        vm.stopBroadcast();
    }
}
