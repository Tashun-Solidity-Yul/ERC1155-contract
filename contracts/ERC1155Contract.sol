// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./utils/ContractUtil.sol";

contract ERC1155Contract is ERC1155, ContractUtil {

    constructor() ERC1155(initialURI) {
    }

    function changeTokenURI(uint256 tokenId) private {
        if (!tokenValidationMap[tokenId]) {
            revert TokenDoesNotExist();
        }
        _setURI(tokenMap[tokenId]);
    }


    /**
        tokenId - token Id user would like to mint/forge
        amount - unit of token Ids user would like to mint/forge
    */
    function startMintingToken(uint256 tokenId, uint256 amount) external payable {
        // check if the tokens are among 0,1,2,3,4,5,6
        checkIfTokenIsValid(tokenId);
        // amount can not be zero
        isAmountZero(amount);
        // implement the token dependency logic
        isEligibleToMintTokenId(tokenId, amount);
        // restrict null address and contract Addresses
        authorizeAddress(msg.sender);
        // get minting price for the selectedToken
        uint256 mintingPrice = getMiningPriceForToken(tokenId);
        if (msg.value < mintingPrice) {
            revert InSufficientMatic();
        }
        forgeOrMintTokens(tokenId, amount);
    }

    function forgeOrMintTokens(uint256 tokenId, uint256 amount) private {
        if (tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) {
            burnTokensInForgingProcess(tokenId, amount);
        }
        _mint(msg.sender, tokenId, amount, "");
    }

}
