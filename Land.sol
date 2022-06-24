//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";

struct Lands {
    address _owner;
    mapping(uint => address) previousOwners;
    address _renter;
    uint _price;
    uint _rentPrice;
    uint _dueDate;
    bool _sold;
    bool _created;
    bool _rented;
    bool _rentOut;
    uint _ownerCount;
    string _uri;
}


contract Land is ERC721 {
    address _admin;
    mapping(uint => Lands) _lands;
    uint _landId;
    uint _balance;

    constructor() ERC721("MXR Collectibles", "MXRT") {
        _admin = msg.sender;
        _landId = 1;
    }

//Start Event
    event Create(uint indexed landId, uint price, string indexed uri);
    event Buy(address indexed from, address indexed to, uint indexed landId, uint price);
    event Sell(address indexed owner, uint indexed landId, uint price);
    event RentOut(address indexed owner, uint indexed landId, uint price);
    event Rent(address indexed from, address indexed to, uint indexed landId, uint price);
//End Event

//Start Modifier
    modifier onlyAdmin {
        require(msg.sender == _admin, "Unauthorized");
        _;
    }

    modifier onlyOwner(uint landId) {
        require(msg.sender == _lands[landId]._owner, "Unauthorized");
        _;
    }

    modifier notOwner(uint landId) {
        require(msg.sender != _lands[landId]._owner, "You are owner");
        _;
    }

    modifier onlyRenter(uint landId) {
        require(msg.sender == _lands[landId]._renter, "Unauthorized");
        _;
    }

    modifier landCreated(uint landId) {
        require(_lands[landId]._created, "This land wasn't created");
        _;
    }

    modifier landNotCreated(uint landId) {
        require(!_lands[landId]._created, "This land was created");
        _;
    }

    modifier landSold(uint landId) {
        require(_lands[landId]._sold, "This land wasn't sold");
        _;
    }

    modifier landNotSold(uint landId) {
        require(!_lands[landId]._sold, "This land was sold");
        _;
    }

    modifier haveOwner(uint landId) {
        require(_lands[landId]._owner != address(0), "This land hasn't owner");
        _;
    }

    modifier haveNotOwner(uint landId) {
        require(_lands[landId]._owner == address(0), "This land has owner");
        _;
    }

    modifier landRented(uint landId) {
        require(_lands[landId]._rented, "This land wasn't rented");
        _;
    }

    modifier landNotRented(uint landId) {
        require(!_lands[landId]._rented, "This land was rented");
        _;
    }

    modifier landRentOut(uint landId) {
        require(_lands[landId]._rentOut, "This land isn't renting out");
        _;
    }

    modifier landNotRentOut(uint landId) {
        require(!_lands[landId]._rentOut, "This land is renting out");
        _;
    }

    modifier buyPlusMatch(uint landId) {
        require(msg.value == _lands[landId]._price + (_lands[landId]._price / 20), "Money is not match");
        _;
    }

    modifier buyMinusMatch(uint landId) {
        require(msg.value == _lands[landId]._price, "Money is not match");
        _;
    }

    modifier rentMatch(uint landId) {
        require(msg.value == _lands[landId]._rentPrice, "Money is not match");
        _;
    }
//End Modifier

    function CreateLand(uint price, string memory uri) public onlyAdmin landNotCreated(_landId) {
        _lands[_landId]._price = price;
        _lands[_landId]._created = true;
        _lands[_landId]._uri = uri;

        emit Create(_landId, price, uri);

        _landId++;
    }

    function PlusBuyLand(uint landId, uint metaverseXrFee, uint previousOwnerFee, uint referalFee, address refAddress) public payable notOwner(landId) buyPlusMatch(landId) landNotSold(landId) landCreated(landId) {
        
        address from = _lands[landId]._owner;
        uint price = _lands[landId]._price;

        if(_lands[landId]._owner == address(0)) {
            _lands[landId]._owner = msg.sender;
            _lands[landId]._sold = true;
            _balance += msg.value;
            
            _mint(msg.sender, landId, _lands[_landId]._uri);
        }
        else if(_lands[landId]._owner != address(0)) {
            payable(_lands[landId]._owner).transfer(price);
            payable(_admin).transfer(metaverseXrFee);
            for (uint i = 1; i < 6; i++) {
                if (_lands[landId].previousOwners[i] != address(0)) {
                    payable(_lands[landId].previousOwners[i]).transfer(previousOwnerFee);
                }
                else {
                    continue;
                }
            }
            payable(refAddress).transfer(referalFee);
            
            _lands[landId]._owner = msg.sender;
            _lands[landId]._sold = true;
            
            _mint(msg.sender, landId, _lands[_landId]._uri);
        }

        emit Buy(from, msg.sender, landId, msg.value);
    }

    function MinusBuyLand(uint landId, uint metaverseXrFee, uint previousOwnerFee, uint referalFee, address refAddress) public payable notOwner(landId) buyMinusMatch(landId) landNotSold(landId) landCreated(landId) {

        address from = _lands[landId]._owner;
        uint price = _lands[landId]._price - (_lands[landId]._price / 20);

        if(_lands[landId]._owner == address(0)) {
            _lands[landId]._owner = msg.sender;
            _lands[landId]._sold = true;
            _balance += msg.value;
            
            _mint(msg.sender, landId, _lands[_landId]._uri);
        }
        else if(_lands[landId]._owner != address(0)) {
            payable(_lands[landId]._owner).transfer(price);
            payable(_admin).transfer(metaverseXrFee);
            for (uint i = 1; i < 6; i++) {
                if (_lands[landId].previousOwners[i] != address(0)) {
                    payable(_lands[landId].previousOwners[i]).transfer(previousOwnerFee);
                }
                else {
                    continue;
                }
            }
            payable(refAddress).transfer(referalFee);
            
            _lands[landId]._owner = msg.sender;
            _lands[landId]._sold = true;
            
            _mint(msg.sender, landId, _lands[_landId]._uri);
        }

        emit Buy(from, msg.sender, landId, msg.value);
    }

    function SellLand(uint landId, uint price) public onlyOwner(landId) landNotRented(landId) {
        _lands[landId]._price = price;
        _lands[landId]._sold = false;
        _lands[landId]._rentOut = false;

        _lands[landId]._ownerCount++;

        if(_lands[landId]._ownerCount >= 6) {
            _lands[landId]._ownerCount = 1;
        }

        if(_lands[landId].previousOwners[_lands[landId]._ownerCount] != msg.sender){
            _lands[landId].previousOwners[_lands[landId]._ownerCount] = msg.sender;
        }

        _burn(landId);

        emit Sell(msg.sender, landId, price);
    }

    function RentOutLand(uint landId, uint rentPrice) public onlyOwner(landId) {
        _lands[landId]._rentPrice = rentPrice;
        _lands[landId]._rentOut = true;

        emit RentOut(msg.sender, landId, rentPrice);
    }

    function RentLand(uint landId) public payable notOwner(landId) rentMatch(landId) landRentOut(landId) {
        payable(_lands[landId]._owner).transfer(_lands[landId]._rentPrice);
        _lands[landId]._renter = msg.sender;
        _lands[landId]._rented = true;
        _lands[landId]._rentOut = false;
        _lands[landId]._dueDate = block.timestamp + 30 days;

        emit Rent(_lands[landId]._owner, msg.sender, landId, _lands[landId]._rentPrice);
    }

    function DueDate(uint landId) public landRented(landId) onlyOwner(landId) {
        if(block.timestamp >= _lands[landId]._dueDate) {
            _lands[landId]._renter = address(0);
        }
    }

    function ViewDueDate(uint landId) public view landRented(landId) returns(uint dueDate) {
        return _lands[landId]._dueDate;
    }

    function Owner(uint landId) public view haveOwner(landId) returns(address owner) {
        return _lands[landId]._owner;
    }

    function Price(uint landId) public view landCreated(landId) returns(uint price) {
        return _lands[landId]._price;
    }

    function RentPrice(uint landId) public view landCreated(landId) landRentOut(landId) returns(uint price) {
        return _lands[landId]._rentPrice;
    }

    function RentingOut(uint landId) public view landCreated(landId) haveOwner(landId) returns(bool rentingOut) {
        return _lands[landId]._rentOut;
    }

    function Renter(uint landId) public view landRented(landId) returns(address renter) {
        return _lands[landId]._renter;
    }

    function StatusSold(uint landId) public view landCreated(landId) returns(bool sold) {
        return _lands[landId]._sold;
    }

    function Balance() public view returns(uint balance) {
        return _balance;
    }

    function PrevOwner(uint landId, uint prevNum) public view returns(address prevOwner) {
        return _lands[landId].previousOwners[prevNum];
    }
}
