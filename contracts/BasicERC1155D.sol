// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./baseContracts/ERC1155D.sol";

/**
 * @title ERC1155D example implementation
 */
contract BasicERC1155D is ERC1155, Ownable {
    
    uint256 index = 1;


    //Token config.
    uint256 public constant PRICE = 0.1 ether;

    event NFTMinted(uint256, uint256, address);

    constructor() ERC1155("ipfs://some_IPFS_CID/{id}.json") {}

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

       ///@notice mints @param number of tokens to msg.sender
    function mintNFTs(uint256 _number) public payable {
        require(msg.value == PRICE * _number, "Not enought/Too much ether sent");
        
        for (uint i = 0; i < _number; ++i) {
            uint256 _currentId = index;
            _mint(msg.sender, _currentId, 1, '');

            unchecked{
                index = _currentId++;
            }
        }
        emit NFTMinted(_number, this.getCurrentId(), msg.sender);

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
