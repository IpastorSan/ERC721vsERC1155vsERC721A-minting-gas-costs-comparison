// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BasicERC1155 is ERC1155, Ownable  {
    
    //Token config.
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant PRICE = 0.1 ether;
    
    uint256 index = 1;

    event NFTMinted(uint256, uint256, address);

    constructor() ERC1155("ipfs://some_IPFS_CID/{id}.json") {
    }

   
    ///@notice mints @param number of tokens to msg.sender
    function mintNFTs(uint256 _number) public payable {
        uint256 _totalMinted = index;

        require(msg.value == PRICE * _number, "Not enought/Too much ether sent");
        require(_totalMinted < MAX_SUPPLY, "Not enought tokens in collection");
       
        
        for (uint i = 0; i < _number; ++i) {
            uint256 _currentId = index;
            _mint(msg.sender, index, 1, "0x");
            unchecked {
                index = ++_currentId;
            }
        }

        emit NFTMinted(_number, index, msg.sender);

        }

    /// @dev this function is only for testing the gas cost purposes.
    /// It BREAKS all the index logic, dont use in a real world contract if
    /// you already have mintNFTS
    function mintBatchNFT(uint256 _number) public payable {
        uint256 _totalMinted = index;
        
        require(tx.origin == msg.sender, "The caller is another contract");
        require(msg.value == PRICE * _number, "Not enought/Too much ether sent");
        require(_totalMinted < MAX_SUPPLY, "Not enought tokens in collection");

        _mint(msg.sender, _totalMinted, _number, "0x");
        unchecked {
            index = _totalMinted++;
    }
        }
        


    function getCurrentId() external view returns(uint256){
        return index;
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