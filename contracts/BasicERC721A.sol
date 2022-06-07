// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;


import "@openzeppelin/contracts/access/Ownable.sol";

import "erc721a/contracts/ERC721A.sol";



contract BasicERC721A is ERC721A, Ownable{

    //comparisons are strictly less than for gas efficiency.
    uint256 numberOfTokensMinted;
    uint256 public constant MAX_SUPPLY = 10001;
    uint256 public constant PRICE = 0.1 ether;

    string public baseTokenURI;

    event NFTMinted(uint256, uint256, address);

    //amount of mints that each address has executed.
    mapping(address => uint256) public mintsPerAddress;

    constructor(string memory baseURI) ERC721A("BlueGhost", "BGH") {
        baseTokenURI = baseURI;
        
    }

    function _baseURI() internal view override returns (string memory) {
       return baseTokenURI;
    }
    
    /// @dev changes BaseURI and set it to the true URI for collection
    /// @param revealedTokenURI new token URI. Format required ipfs://CID/
    function reveal(string memory revealedTokenURI) public onlyOwner {
        baseTokenURI = revealedTokenURI;
    }

    ///@dev returns current tokenId. There is no burn function so it can be assumed to be sequential
    function tokenId() external view returns(uint256) {
        if (numberOfTokensMinted == 0) {
            return 0;
        } else {
            uint currentId = numberOfTokensMinted - 1;
            return currentId;
        }
    }

    /// @dev mint @param _number of NFTs in one batch.
    function mintNFTs(uint256 _number) public payable {
        uint256 totalMinted = numberOfTokensMinted;

        require(totalMinted + _number < MAX_SUPPLY, "Not enough NFTs!");
        require(msg.value == PRICE * _number , "Not enough/too much ether sent");
        
        mintsPerAddress[msg.sender] += _number;

        _safeMint(msg.sender, _number);
        numberOfTokensMinted += _number;

        emit NFTMinted(_number, this.tokenId(), msg.sender);
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
    
