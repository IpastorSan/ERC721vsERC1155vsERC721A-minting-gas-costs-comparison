# NFT minting gas cost comparison.

Comparison of gas costs and their evolution for different ERC standards that can be used to make an NFT contract.
- ERC721, implementation by Openzeppelin. By far the most used, it is not the cheapest gas-cost wise but it comes with some good tradeoffs like readability, simplicity and the fact that they have been going around enough time that you can consider them one of the safest implementations.[More Info](https://docs.openzeppelin.com/contracts/4.x/erc721) | [Github Repo](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol)
- ERC721A, implementation by Chiru Labs and used first in the Azuki collection. It has been making a lot of noise lately and for good reason, its perfomance for batch minting is by far the best in the comparison, except for minting a single NFT. As a tradeoff, the transfer of tokens are more expensive than with Openzeppelin's implementation.[More Info](https://www.azuki.com/erc721a) | [Github Repo](https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol)
- ERC1155 by Openzeppelin. Technically the "semi-fungible" standard, you can force its behaviour to be like an ERC721. Each mint creates a 1/1 token, effectively making it an NFT. It is more cost efficient than ERC721, but less than ERC721A. [More Info](https://docs.openzeppelin.com/contracts/4.x/erc1155) | [Github Repo](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol)
- ERC1155D by DonkeVerse. Interesting implementation for 1/1 editions. Not as efficient with batch minting but an interesting implementation. You will notice that the article in the link claims that it can achieve a mint cost of 51072. This is indeed true if the optimizer is set to 10.000 and the index tracking is optimized within the loop. On the first phase, I decided not to make these optimizations so we can test all the contracts with the same conditions. Even so, it is still the most efficient by far with token transfers. [More Info](https://medium.com/donkeverse/introducing-erc1155d-the-most-efficient-non-fungible-token-contract-in-existence-c1d0a62e30f1) | [Github Repo](https://github.com/DonkeVerse/ERC1155D/blob/main/contracts/ERC1155D.sol)

I used the gas report from [hardhat-gas-reporter](https://www.npmjs.com/package/hardhat-gas-reporter), just download the repo, set the number of tokens to be minted in the test.js file (line 17) and then use ````npx hardhat test```` 

Gas cost evolution (in gas points)
![gas cost evolution](gas-cost.png)

Gas Cost evolution, assuming 70 Gwei and an ETH price of 1800USD
![Gas cost in usd](gas-cost-usd.png)

Bonus Track: if you ever want to mint 1000 tokens, choose your standard wisely
![BonusTrack](gas-report-1000.png)

## Phase 2. Followed the example of ERC1155D correct use on all contracts
Simple changes in all contracts that decreased the gas cost accross all standards:

- Stopped using ````Counters```` library. 
- Used a variable index initialized to 1 instead of 0 for all contracts. 
- ERC721A has an internal function ````_startTokenId()```` that was interfering with the initialization of index to 1. Override that function.
- Increment index by 1 using ````unchecked```` inside the mint function. Safe since index will never go over 10.000 in our case.
- Added ````require(tx.origin == msg.sender, "The caller is another contract");```` to all contracts (except ERC1155D, it brings it by defect) so we can use ````_mint()```` instead of ````_safeMint()````
- Increased Optimizer to 10.000 rounds. It increases the deployment cost (slightly)

The effect on these optimization on ERC1155D are the most striking (I was clearly not implementing it well in the previous versions). Up to 30 tokens it outperforms gas costs of ERC721A. This said, the team does not advice to use it in production yet, as it has not been formally audited.

On average this saves
- ERC721: 46.04% average (except for 1 token -> 17.76%)
- ERC721A: 43.12% average (except for 1 token -> 25.33%)
- ERC1155: 45.66% average (except for 1 token -> 24.75%)
- ERC1155D: 80.9% average (except for 1 token -> 28.05%)

Gas cost evolution (in gas points)
![gas cost evolution](gas-cost-v2.png)

Gas Cost evolution, assuming 70 Gwei and an ETH price of 1800USD
![Gas cost in usd](gas-cost-usd-v2.png)

Bonus Track: if you ever want to mint 1000 tokens, choose your standard wisely
![BonusTrack](gas-report-100v2.png)
