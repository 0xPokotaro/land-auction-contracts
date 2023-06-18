// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import { Test } from "forge-std/Test.sol";
import { AuctionToken } from "../src/FungibleToken/AuctionToken.sol";
import { Land } from "../src/NonFungibleToken/Land.sol";
import { NFTAuction } from "../src/NFTAuction.sol";

contract LandTest is Test {
    bytes4 constant public INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 constant public INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 constant public INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 constant public INTERFACE_ID_ERC2981 = 0x2a55205a;

    // Address
    address constant public RECEIVER = 0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000;

    // Contracts
    Land public land;

    function setUp() public {
        land = new Land(RECEIVER);
    }

    function test_supportsInterface() public {
        assertTrue(land.supportsInterface(INTERFACE_ID_ERC165));
        assertTrue(land.supportsInterface(INTERFACE_ID_ERC721));
        assertTrue(land.supportsInterface(INTERFACE_ID_ERC721_METADATA));
        assertTrue(land.supportsInterface(INTERFACE_ID_ERC2981));

        assertFalse(land.supportsInterface(0xaaaaaaaa));
    }

    function test_setERC6551Registry() public {
        land.setERC6551Registry(RECEIVER);
    }
}
