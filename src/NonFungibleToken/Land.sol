// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ERC721AQueryable } from "erc721a/contracts/extensions/ERC721AQueryable.sol";
import { IERC721A, ERC721A } from "erc721a/contracts/ERC721A.sol";

contract Land is ERC721AQueryable {
    constructor() ERC721A("Auction Land", "LAND") {
    }
}
