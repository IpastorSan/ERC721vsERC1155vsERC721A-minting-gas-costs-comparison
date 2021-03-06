// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicERC721 is ERC721, Ownable {
    uint256 index = 1;

    //comparisons are strictly less than for gas efficiency.
    uint256 public constant MAX_SUPPLY = 10001;
    
    uint256 public constant PRICE = 0.1 ether;

    string public baseTokenURI;

    event NFTMinted(uint256, uint256, address);

    constructor(string memory baseURI) ERC721("NFTContract", "NFT") {
        baseTokenURI = baseURI;
        
    }

    function _baseURI() internal view override returns (string memory) {
       return baseTokenURI;
    }

    /// @dev changes BaseURI and set it to the true URI for collection
    /// @param _newBaseTokenURI new token URI. Format required ipfs://CID/
    function reveal(string memory _newBaseTokenURI) public onlyOwner {
        baseTokenURI = _newBaseTokenURI;
    }


    function mintNFTs(uint256 _number) public payable {
        uint256 _totalMinted = index;

        require(tx.origin == msg.sender, "The caller is another contract");
        require(_totalMinted + _number < MAX_SUPPLY, "Not enough NFTs!");
        require(msg.value == PRICE * _number , "Not enough/too much ether sent");
        

        for (uint i = 0; i < _number; ++i) {
            uint256 _currentId = index;

            _mint(msg.sender, _currentId);

            unchecked {
                index = ++_currentId ;
            }
        }

        emit NFTMinted(_number, index,msg.sender);
    }


    function getCurrentId() public view returns (uint256) {
        return index;
    }

    /// @dev retrieve all the funds obtained during minting
    function withdraw() external onlyOwner {
     uint256 balance = address(this).balance;
     require(balance > 0, "No ether left to withdraw");

     (bool success, ) = payable(owner()).call{value: balance}("");

     require(success, "Transfer failed.");
     
    }

    /// @dev reverts transaction if someone accidentally send ETH to the contract 
    receive() payable external {
        revert();
    }
    
}