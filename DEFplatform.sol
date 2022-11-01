// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EquityToken";

contract DEFplatform {
    
    address owner = msg.sender; //deployer of contract owns DEF platform
    
    //fees
    uint ipoFee = 0;
    uint facilitationFee = 1; //percentage owner gets whenever a mint of an EQT is done

    //registered EQTs
    uint eqtCount = 0;
    mapping(uint => EquityToken) public eqts; //companyId => address to company's personal EQT contract

    //collateral locked by 
    //to ensure unique symbols for every EQT
    mapping(string => bool) public symbolTaken;
    
    //launch company
    function ipo(
        string memory _name, 
        string memory _symbol,  
        uint _amountToRelease, //amount of EQT offered to public (caps the total supply of EQT and thus the mintable EQT amount)
        uint _ownShare, //number defining how much EQT should be minted to owner of company during IPO
        uint _price
    ) payable {
        require(symbolTaken[_symbol] == false);
        EquityToken eqtContract = new EquityToken(
            msg.sender,
            _name,
            _symbol,
            _amountToRelease,
            _ownShare,
            _price,
            address(this)
        );
        eqts[eqtCount] = eqtContract;
        eqtCount++;
    }

    //functions for owner
    // Modifier to check that the caller is the owner of
    // the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setIpoFee(uint _newFee) onlyOwner {
        ipoFee = _newFee;
    }

    function setFacilitationFee(uint _newFee) onlyOwner {
        facilitationFee = _newFee;
    }
}