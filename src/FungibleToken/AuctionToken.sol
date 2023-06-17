// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract AuctionToken is ERC20, ERC20Burnable, Ownable {
    uint8 private constant DECIMALS = 9;
    uint256 private constant INITIAL_SUPPLY = 50 * 10 ** 6 * 10 ** DECIMALS;

    constructor() ERC20("AuctionToken", "ACT") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }
}
