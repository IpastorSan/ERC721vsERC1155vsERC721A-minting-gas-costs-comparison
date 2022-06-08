const { ethers} = require("hardhat");
const { expect } = require("chai");


describe("ERC721, ERC721A, ERC1155, ERC1155D minting for gas comparison", () => {
  let erc721Factory;
  let erc721aFactory;
  let erc1155Factory;
  let erc1155FactoryD;
  let erc721;
  let erc721a;
  let erc1155;
  let erc1155d;
  let owner;
  let alice;
  let bob;
  let amount = 5;

  beforeEach(async () => {
    let signers = await ethers.getSigners()
    ownerAccount = signers[0]
    aliceAccount = signers[1]
    bobAccount = signers[2]
    carolAccount = signers[3]
    ineAccount = signers[4]

    owner = ownerAccount.address
    alice = aliceAccount.address 
    bob = bobAccount.address
    carol = carolAccount.address
    ine = ineAccount.address

    erc721Factory = await ethers.getContractFactory("BasicERC721")
    erc721aFactory = await ethers.getContractFactory("BasicERC721A")
    erc1155Factory = await ethers.getContractFactory("BasicERC1155")
    erc1155dFactory = await ethers.getContractFactory("BasicERC1155D")

    const baseTokenUri = "https://ipfs.io/ipfs/whatever/"
    
    erc721 = await erc721Factory.deploy(baseTokenUri)
    erc721a = await erc721aFactory.deploy(baseTokenUri)
    erc1155 = await erc1155Factory.deploy()
    erc1155d = await erc1155dFactory.deploy()



  })

  describe(`Minting ${amount} unit of each token`, () => {

    it(`Should allow user to mint erc721 ${amount} token with exact price`, async () => {
      await erc721.connect(aliceAccount).mintNFTs(amount, {value: ethers.utils.parseEther(`${0.1*amount}`)})
      expect(await erc721.balanceOf(alice)).to.be.equal(amount)
    })

    it(`Should allow user to mint erc721a ${amount} token with exact price`, async () => {
      await erc721a.connect(aliceAccount).mintNFTs(amount, {value: ethers.utils.parseEther(`${0.1*amount}`)})
      expect(await erc721a.balanceOf(alice)).to.be.equal(amount)
    })

    it(`Should allow user to serially mint erc1155 ${amount} token with exact price`, async () => {
      await erc1155.connect(aliceAccount).mintNFTs(amount, {value: ethers.utils.parseEther(`${0.1*amount}`)})
      expect(await erc1155.balanceOf(alice, amount)).to.be.equal(1)
    })

    it(`Should allow user to batch mint erc1155 ${amount} token with exact price`, async () => {
      await erc1155.connect(aliceAccount).mintBatchNFT(amount, {value: ethers.utils.parseEther(`${0.1*amount}`)})
      expect(await erc1155.balanceOf(alice, await erc1155.getCurrentId())).to.be.equal(amount)
    })

    it(`Should allow user to mint erc1155D ${amount} token with exact price`, async () => {
      await erc1155d.connect(aliceAccount).mintNFTs(amount, {value: ethers.utils.parseEther(`${0.1*amount}`)})
      expect(await erc1155d.balanceOf(alice, await erc1155d.getCurrentId())).to.be.equal(1)
    })

  })


  describe("Transfer of tokens", () => {

    it(`Should mint by Alice and try to transfer ${1} erc721 token from user Alice to user Carol`, async () => {
      await erc721.connect(aliceAccount).mintNFTs(1, {value: ethers.utils.parseEther(`${0.1}`)})
      
      await erc721.connect(aliceAccount).transferFrom(alice, carol, 1)
      
      expect(await erc721.balanceOf(alice)).to.be.equal(0)
      expect(await erc721.balanceOf(carol)).to.be.equal(1)
    })

    it(`Should mint by Alice and try to transfer ${1} erc721a token from user Alice to user Carol`, async () => {
      await erc721a.connect(aliceAccount).mintNFTs(1, {value: ethers.utils.parseEther(`${0.1}`)})
      
      await erc721a.connect(aliceAccount).transferFrom(alice, carol, 1)
      
      expect(await erc721a.balanceOf(alice)).to.be.equal(0)
      expect(await erc721a.balanceOf(carol)).to.be.equal(1)
    })

    it(`Should mint by Alice and try to transfer ${1} erc1155 token from user Alice to user Carol`, async () => {
      await erc1155.connect(aliceAccount).mintNFTs(1, {value: ethers.utils.parseEther(`${0.1}`)})

      
      await erc1155.connect(aliceAccount).safeTransferFrom(alice, carol, 1, 1, "0x")
      

      expect(await erc1155.balanceOf(alice, 1)).to.be.equal(0)
      expect(await erc1155.balanceOf(carol, 1)).to.be.equal(1)
    })

    it(`Should mint by Alice and try to transfer ${1} erc1155D token from user Alice to user Carol`, async () => {
      await erc1155d.connect(aliceAccount).mintNFTs(1, {value: ethers.utils.parseEther(`${0.1}`)})

      
        await erc1155d.connect(aliceAccount).safeTransferFrom(alice, carol, 1, 1, "0x")
      

      expect(await erc1155d.balanceOf(alice, 1)).to.be.equal(0)
      expect(await erc1155d.balanceOf(carol, 1)).to.be.equal(1)
    })

    
  })
  

})