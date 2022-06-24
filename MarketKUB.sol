//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OCN.sol";

contract Market is OCN {

    mapping(address =>mapping(uint256 => Listing)) public listings;

    struct Listing {
        uint256 price;
        address seller;
        address owner;
        bool isListing;
        uint ownerCount;
        mapping(uint => address) previousOwners;
    }

    function addListing(uint256 price, address contractAddr, uint256 tokenId) public {
        ERC1155 token = ERC1155(contractAddr);
        require(token.balanceOf(msg.sender, tokenId) > 0, "Seller has no token.");
        require(token.isApprovedForAll(msg.sender, address(this)), "Contract must be approved.");

        listings[contractAddr][tokenId].price = price;
        listings[contractAddr][tokenId].seller = msg.sender;
        listings[contractAddr][tokenId].owner = msg.sender;
        listings[contractAddr][tokenId].isListing = true;
    }

    function cancelListing(address contractAddr, uint256 tokenId) public {
        ERC1155 token = ERC1155(contractAddr);
        Listing storage item = listings[contractAddr][tokenId];
        require(item.seller == msg.sender, "Unauthorized.");
        require(item.isListing, "This NFT is not listing.");
        require(token.isApprovedForAll(msg.sender, address(this)), "Contract must be approved.");

        listings[contractAddr][tokenId].isListing = false;
    }

    function purchase(address contractAddr, uint256 tokenId, address referer, uint256 metaverseFee, uint256 previousOwnerFee, uint256 referalFee) public payable {
        Listing storage item = listings[contractAddr][tokenId];
        ERC1155 token = ERC1155(contractAddr);
        require(item.isListing, "This NFT is not for sell.");
        require(msg.sender != item.seller, "Buy from yourself.");
        require(msg.value >= item.price, "Insufficient funds sent.");
        payable(item.seller).transfer(item.price - (item.price / 20));
        payable(owner()).transfer(metaverseFee);
        if(referer != address(0)){
            payable(referer).transfer(referalFee);
        }
        for (uint i = 0; i < 5; i++) {
                if (item.previousOwners[i] != address(0)) {
                    payable(item.previousOwners[i]).transfer(previousOwnerFee);
                }
                else {
                    break;
                }
            }

        token.safeTransferFrom(item.seller, msg.sender, tokenId, 1, "");
        item.owner = msg.sender;
        if(listings[contractAddr][tokenId].ownerCount <= 3) {
            item.previousOwners[item.ownerCount] = item.seller;
            item.ownerCount += 1;
        }
        else {
            item.previousOwners[item.ownerCount] = item.seller;
            item.ownerCount = 0;
        }

        item.isListing = false;
    }

    function purchaseBatch(address contractAddr, uint256[] calldata tokenId, address referer, uint256 metaverseFee, uint256[] calldata previousOwnerFee, uint256 referalFee) public payable {
        for (uint j = 0; j < tokenId.length; j++) {
            Listing storage item = listings[contractAddr][tokenId[j]];
            ERC1155 token = ERC1155(contractAddr);
            require(item.isListing, "This NFT is not for sell.");
            require(msg.sender != item.seller, "Buy from yourself.");
            require(msg.value >= item.price, "Insufficient funds sent.");
            payable(item.seller).transfer(item.price - (item.price / 20));
            payable(owner()).transfer(metaverseFee);
            if(referer != address(0)){
                payable(referer).transfer(referalFee);
            }
            for (uint i = 0; i < 5; i++) {
                    if (item.previousOwners[i] != address(0)) {
                        payable(item.previousOwners[i]).transfer(previousOwnerFee[j]);
                    }
                    else {
                        break;
                    }
                }

            token.safeTransferFrom(item.seller, msg.sender, tokenId[j], 1, "");
            item.owner = msg.sender;
            if(item.ownerCount <= 3) {
                item.previousOwners[item.ownerCount] = item.seller;
                item.ownerCount += 1;
            }
            else {
                item.previousOwners[item.ownerCount] = item.seller;
                item.ownerCount = 0;
            }

            item.isListing = false;
        }
    }

    function getPrice(address contractAddr, uint tokenId) public view returns(uint256 price) {
        return listings[contractAddr][tokenId].price;
    }

    function getSeller(address contractAddr, uint tokenId) public view returns(address seller) {
        return listings[contractAddr][tokenId].seller;
    }

    function getIsListing(address contractAddr, uint tokenId) public view returns(bool isListing) {
        return listings[contractAddr][tokenId].isListing;
    }

    function getPrevOwner(address contractAddr, uint tokenId, uint prevIndex) public view returns(address prevOwner) {
        return listings[contractAddr][tokenId].previousOwners[prevIndex];
    }

    function getOwner(address contractAddr, uint tokenId) public view returns(address owner) {
        return listings[contractAddr][tokenId].owner;
    }
}
