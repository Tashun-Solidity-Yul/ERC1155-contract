// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./BaseContract.sol";


contract GameContract is BaseContract {


    constructor(ERC1155BaseContract initialContract) BaseContract(initialContract) {
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

    function startBurningToken(uint256 tokenId, uint256 amount) external {
        // check if the tokens are among 0,1,2,3,4,5,6
        checkIfTokenIsValid(tokenId);
        // amount can not be zero
        isAmountZero(amount);
        // check availabilities
        isEligibleToBurn(tokenId, amount);
        // restrict null address and contract Addresses
        authorizeAddress(msg.sender);
        // burn tokens
        baseContract.burnToken(msg.sender, tokenId, amount);
        emit ActionNotifier(msg.sender);
    }

    function startTransferringToken(uint256 fromTokenId, uint256 toTokenId, uint256 amount) external {
        //fromTokenId should not be equal to toTokenId
        checkIfTransferTokenAreSame(fromTokenId, toTokenId);
        // check if the tokens are among 0,1,2,3,4,5,6
        checkIfTokenIsValid(fromTokenId);
        checkIfTokenIsValid(toTokenId);
        // amount can not be zero
        isAmountZero(amount);
        // check availabilities
        isEligibleToTransfer(fromTokenId, amount, true);
        isEligibleToTransfer(toTokenId, amount, false);

        // restrict null address and contract Addresses
        authorizeAddress(msg.sender);
        // burn tokens
        baseContract.burnToken(msg.sender, fromTokenId, amount);
        baseContract.mintToken(msg.sender, toTokenId, amount);
        emit ActionNotifier(msg.sender);
    }

    function balanceOf(address account, uint256 tokenId) external view returns (uint256 returningBalance){
        returningBalance = baseContract.balanceOf(account, tokenId);
    }

}
