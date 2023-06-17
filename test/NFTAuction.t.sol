// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/FungibleToken/AuctionToken.sol";
import "../src/NFTAuction.sol";


contract NFTAuctionTest is Test {
    // Contracts
    AuctionToken public auctionToken;
    NFTAuction public nftAuction;

    function setUp() public {
        auctionToken = new AuctionToken();
        nftAuction = new NFTAuction(bytes32("a"), address(auctionToken), block.timestamp);
    }
}
