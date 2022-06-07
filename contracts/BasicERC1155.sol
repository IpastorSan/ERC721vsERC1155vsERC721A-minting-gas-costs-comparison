// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract BasicERC1155 is ERC1155, Ownable  {
    
    //Token config.
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant PRICE = 0.1 ether;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

     event NFTMinted(uint256, uint256, address);

    constructor() ERC1155("ipfs://some_IPFS_CID/{id}.json") {
    }

   
    ///@notice mints @param number of tokens to msg.sender
    function mintNFTs(uint256 _number) public payable {
        uint256 _totalMinted = _tokenIds.current();

        require(msg.value == PRICE * _number, "Not enought/Too much ether sent");
        require(_totalMinted < MAX_SUPPLY, "Not enought tokens in collection");
       
        
        for (uint i = 0; i < _number; ++i) {
            _mintSingleNFT();
        }

        emit NFTMinted(_number, this.getCurrentId(), msg.sender);

        }

    function _mintSingleNFT() internal {
      uint _newTokenID = _tokenIds.current();
      _mint(msg.sender, _newTokenID, 1, "0x");
      _tokenIds.increment();

    }

    function mintBatchNFT(uint256 _number) public payable {
        uint256 _totalMinted = _tokenIds.current();

        require(msg.value == PRICE * _number, "Not enought/Too much ether sent");
        require(_totalMinted < MAX_SUPPLY, "Not enought tokens in collection");

        _mint(msg.sender, _totalMinted, _number, "0x");
        _tokenIds.increment();
    }


    function getCurrentId() external view returns(uint256){
        return _tokenIds.current();
    }

    /// @dev retrieve all the funds obtained during minting
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        require(balance > 0, "No funds left to withdraw");

        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {
        revert();
    }

}