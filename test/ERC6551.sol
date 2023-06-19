// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import { ERC6551AccountProxy } from "src/ERC6551/ERC6551AccountProxy.sol";
import { ERC6551Registry } from "src/ERC6551/ERC6551Registry.sol";
import { Land } from "src/NonFungibleToken/Land.sol";
import { Helper } from "test/helper/Helper.sol";

contract ERC6551Test is Helper {
    // Addresses
    address public receiver = 0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000;

    // Contracts
    ERC6551AccountProxy public proxyContract;
    ERC6551Registry public registryContract;
    Land public landContract;

    function setUp() public {
        // Deploy proxy contract
        proxyContract = new ERC6551AccountProxy(address(this));
        proxyContract.initialize();

        // Deploy registry contract
        registryContract = new ERC6551Registry();

        // Deploy nft contract
        landContract = new Land(receiver);
        landContract.mint(11);
    }

    function test_createAccount() public {
        address landTokenAddress = address(landContract);
        uint256 tokenId = 0;
        
        // 0をbytesに変換すると0xとなる
        bytes memory initData = bytes(uint256(0));

        address newAccount = registryContract.createAccount(
            address(proxyContract),
            CHAIN_ID_SEPOLIA,
            landTokenAddress,
            tokenId,
            0,
            initData
        );

        console2.log("newAccount", newAccount);
    }
}
