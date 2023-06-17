// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { DefaultOperatorFilterer } from "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import { ERC721AQueryable } from "erc721a/contracts/extensions/ERC721AQueryable.sol";
import { IERC721A, ERC721A } from "erc721a/contracts/ERC721A.sol";
import { IERC2981, ERC2981 } from "openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Land is ERC721AQueryable, ERC2981, DefaultOperatorFilterer, Ownable {
    constructor(address _tresary, uint96 _feeNumerator) ERC721A("Auction Land", "LAND") {
        _setDefaultRoyalty(_tresary, _feeNumerator);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC721A, ERC721A, ERC2981)
        returns (bool)
    {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return
            ERC721A.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator)
        external
        onlyOwner
    {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    )
        public
        virtual
        override(ERC721A, IERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    )
        public
        payable
        override(ERC721A, IERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(ERC721A, IERC721A)
        onlyAllowedOperator(from)
    {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    )
        public
        payable
        override(ERC721A, IERC721A)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    )
        public
        payable
        override(ERC721A, IERC721A)
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
