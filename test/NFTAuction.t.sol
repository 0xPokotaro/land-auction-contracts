// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { AuctionToken } from "../src/FungibleToken/AuctionToken.sol";
import { Land } from "../src/NonFungibleToken/Land.sol";
import { NFTAuction } from "../src/NFTAuction.sol";


contract NFTAuctionTest is Test {
    // Address
    address constant public TRESARY = 0xA7a5Fd8481b4e27F5Dd87C4eB9703B741A7F0000;

    // Contracts
    AuctionToken public auctionToken;
    Land public land;
    NFTAuction public nftAuction;

    function setUp() public {
        auctionToken = new AuctionToken();
        land = new Land(TRESARY);
        nftAuction = new NFTAuction(bytes32("a"), address(auctionToken), block.timestamp);
    }
}
