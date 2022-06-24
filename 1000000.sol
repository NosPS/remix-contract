// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC1155.sol";
import "./Ownable.sol";

import {Base64} from "./Base64.sol";

contract OCN is ERC1155, Ownable {
    string public name = "OnChain Collectibles";
    string public symbol = "OCN";

    constructor() ERC1155("", 0) {}

    function setURI(string memory newuri, uint256 tokenId) public onlyOwner {
        _setURI(newuri, tokenId);
    }

    function simplifiedFormatTokenURI(string memory imageURI, string memory _name, string memory _description)
    public
    pure
    returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "',_name,'", "description": "',_description,'", "image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }

    function mint(uint256 amount, bytes memory data, string memory imageURI, string memory _name, string memory _description)
        public
        onlyOwner
    {
        for (uint i = 0; i < amount; i++) {
                setURI(simplifiedFormatTokenURI(imageURI, _name, _description), i);
                _mint(_msgSender(), i, 1, data);
        }
    }

    function mintBatch(uint256[] memory ids, uint256[] memory amounts, bytes memory data, uint256 uriId)
        public
        onlyOwner
    {
        for (uint i = 0; i < ids.length; i++) {
                setURI(uri(uriId), ids[i]);
        }
        _mintBatch(msg.sender, ids, amounts, data);
    }
}