// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MXRT is ERC1155, Ownable {
    string public name = "MXR Collectibles";
    string public symbol = "MXRT";

    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmZdMKFPtGXNnkvC5T1kMEJ8rHPmEnWf9ZQiXiUQ8kr7Vu") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(_msgSender(), id, amount, data);
    }

    function mintBatch(uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(msg.sender, ids, amounts, data);
    }
}