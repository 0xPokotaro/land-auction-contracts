// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

abstract contract Helper {
    // Chain ids
    uint256 constant public CHAIN_ID_MAINNET = 1;
    uint256 constant public CHAIN_ID_SEPOLIA = 11155111;

    // Interface ids
    bytes4 constant public INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 constant public INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 constant public INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 constant public INTERFACE_ID_ERC2981 = 0x2a55205a;

    // Users
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(3);
    address user4 = address(4);
    address user5 = address(5);

    constructor() {}
}
