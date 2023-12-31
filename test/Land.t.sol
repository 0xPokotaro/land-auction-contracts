// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import { AuctionToken } from "../src/FungibleToken/AuctionToken.sol";
import { Land } from "../src/NonFungibleToken/Land.sol";
import { NFTAuction } from "../src/NFTAuction.sol";
import { Helper } from "./helper/Helper.sol";
import { Test } from "forge-std/Test.sol";

contract LandTest is Test, Helper {
    // Addresses
    address constant public RECEIVER = 0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000;

    // Contracts
    Land public landContract;

    function setUp() public {
        landContract = new Land(RECEIVER);
    }

    function test_supportsInterface() public {
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC165));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC721));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC721_METADATA));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC2981));

        assertFalse(landContract.supportsInterface(0xaaaaaaaa));
    }
}
