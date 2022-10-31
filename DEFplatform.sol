// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EquityToken";

contract DEFplatform {
    
    address owner = msg.sender; //deployer of contract owns DEF platform
    
    //fees
    uint ipoFee = 0;
    uint facilitationFee = 1; //percentage owner gets whenever a mint of an EQT is done

    uint companyCount = 0;
    mapping(uint => address) public companies; //companyId => address to company's personal EQT contract

    //to ensure unique symbols for every EQT
    mapping(string => bool) public symbolTaken;
    
    //launch company
    function ipo(
        string memory _name, 
        string memory _symbol,  
        uint _ownShare, //number defining how much EQT should be minted to owner of company during IPO
        uint _releasedAmount, //caps the total supply
        uint _price
    ) onlyOwner payable {
        require(symbolTaken[_symbol] == false);
        EquityToken eqtContract = new EquityToken();
        
    }

    //functions for owner
    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}