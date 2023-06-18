// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import { AuctionToken } from "../src/FungibleToken/AuctionToken.sol";
import { Land } from "../src/NonFungibleToken/Land.sol";
import { NFTAuction } from "../src/NFTAuction.sol";
import { Helper } from "./helper/Helper.sol";
import { Test } from "forge-std/Test.sol";
import { ERC6551Registry } from "reference/ERC6551Registry.sol";
import { ERC6551AccountLib } from "reference/lib/ERC6551AccountLib.sol";

contract LandTest is Land {
    function mint(uint256 quantity) public {
        _mint(msg.sender, quantity);
    }

    constructor(address _receiver) Land(_receiver) {}
}

contract LandTestCase is Test, Helper {
    // Addresses
    address constant public RECEIVER = 0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000;

    // Contracts
    LandTest public landContract;
    ERC6551Registry public erc6551RegisterContract;

    function setUp() public {
        landContract = new LandTest(RECEIVER);
        erc6551RegisterContract = new ERC6551Registry();
    }

    function test_supportsInterface() public {
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC165));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC721));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC721_METADATA));
        assertTrue(landContract.supportsInterface(INTERFACE_ID_ERC2981));

        assertFalse(landContract.supportsInterface(0xaaaaaaaa));
    }

    function test_createAccount() public {
        address implementation = address(0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000);
        uint256 chainId = 1;
        address tokenAddress = address(landContract);
        uint256 tokenId = 1;
        uint256 salt = ERC6551AccountLib.salt();
        bytes memory inputData = abi.encodeWithSignature("mint(uint256)", tokenId);

        address registry = erc6551RegisterContract.createAccount(
            implementation,
            chainId,
            tokenAddress,
            tokenId,
            salt,
            inputData
        );

        console2.log("registry: %s", registry);
    }
}
