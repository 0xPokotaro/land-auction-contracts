// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Land } from "./Land.sol";
import { IERC6551Registry } from "reference/interfaces/IERC6551Registry.sol";

contract PlotLand is Land {
    IERC6551Registry erc6551Registry;
    address erc6551AccountImplementation;

    constructor(address _receiver) Land(_receiver) {}

    /// @dev Sets the address of the ERC6551 registry
    function setERC6551Registry(address _registry)
        public
        onlyOwner
    {
        erc6551Registry = IERC6551Registry(_registry);
    }

    /// @dev Sets the address of the ERC6551 account implementation
    function setERC6551Implementation(address implementation)
        public
        onlyOwner
    {
        erc6551AccountImplementation = implementation;
    }
}
