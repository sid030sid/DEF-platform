// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

import "./DEFplatform";

contract EquityToken is ERC20, ERC20Permit, ERC20Votes {
    DEFplatform immutable defPlatform; //instance of DEF platform to enable interaction between EQT contract and platform

    address issuer; //address of entity issuing EQT  
    uint issuedAmount;
    uint price;
    uint collateral; //optional collateral tied to EQT to make it less risky

    constructor(
        address _issuer, 
        string memory _name, 
        string memory _symbol,
        uint _amountToRelease, //amount of EQT offered to public (caps the total supply of EQT and thus the mintable EQT amount)
        uint _ownShare, //number defining how much EQT should be minted to owner of company during IPO
        uint _price,
        uint _defPlatformAddress
    ) ERC20(_name, _symbol) ERC20Permit("EquityToken") {
        issuer = _issuer;
        issuedAmount = _amountToRelease;
        price = _price;
        defPlatform = DEFplatform(_defPlatformAddress);

        //mint EQT for issuer
        mint(_issuer, _ownShare);
    }

    function mint(address _account, uint256 _amount) payable {
        require(this.totalSupply + _amount <= issuedAmount, "Not enough free EQTs mintable");
        require(price*_amount <= msg.value, "Not enough money to buy EQTs");

        // pay mint and fee
        uint fee = DEFplatform.getFacilitationFee();
        (bool paidMint, ) = issuer.call{value: (price-fee)*_amount}("");
        (bool paidFee, ) = DEFplatform.getOwner().call{value: fee*_amount}("");

        //if payments successful, mint tokens
        require(paidMint && paidFee, "Failed to pay transfer");
        _mint(account, amount);
    }

    //functions only issuer of EQT can use
    modifier onlyIssuer() {
        require(msg.sender == issuer, "Not issuer of EQT");
        _;
    }

    //for e.g. when current issuer sells EQT to another address
    function setIssuer(address _newIssuer) onlyIssuer payable {
        issuer = _newIssuer;
    }

    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}