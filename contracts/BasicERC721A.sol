// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


import "@openzeppelin/contracts/access/Ownable.sol";

import "erc721a/contracts/ERC721A.sol";



contract BasicERC721A is ERC721A, Ownable{

    //comparisons are strictly less than for gas efficiency.

    uint256 public constant MAX_SUPPLY = 10001;
    uint256 public constant PRICE = 0.1 ether;

    string public baseTokenURI;

    event NFTMinted(uint256, uint256, address);

    constructor(string memory baseURI) ERC721A("BlueGhost", "BGH") {
        baseTokenURI = baseURI;
        
    }

    function _baseURI() internal view override returns (string memory) {
       return baseTokenURI;
    }

    function _startTokenId() internal view override returns(uint256){
        return 1;
    }
    
    /// @dev changes BaseURI and set it to the true URI for collection
    /// @param revealedTokenURI new token URI. Format required ipfs://CID/
    function reveal(string memory revealedTokenURI) public onlyOwner {
        baseTokenURI = revealedTokenURI;
    }



    /// @dev mint @param _number of NFTs in one batch.
    function mintNFTs(uint256 _number) public payable {
        uint256 totalMinted = index;

        require(tx.origin == msg.sender, "The caller is another contract");
        require(totalMinted + _number < MAX_SUPPLY, "Not enough NFTs!");
        require(msg.value == PRICE * _number , "Not enough/too much ether sent");

        _mint(msg.sender, _number);
        

        emit NFTMinted(_number, totalSupply(), msg.sender);
    }

    /// @dev retrieve all the funds obtained during minting
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        require(balance > 0, "No funds left to withdraw");

        (bool sent, ) = payable(owner()).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    /// @dev reverts transaction if someone accidentally send ETH to the contract 
    receive() payable external {
        revert();
    }
    
}
    
