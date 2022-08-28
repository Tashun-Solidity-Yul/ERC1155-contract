// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../ERC1155BaseContract.sol";

// General Error Validations
    error TokenDoesNotExist();
    error InvalidWalletAddress();
    error TokenAmountCanNotBeZero();
    error InsufficientTokens();

// Minting and Forging Error Validations
    error InSufficientMatic();

// Trade errors
    error TokenCanNotBeTradedForEqualTokenId();
    error CanNotReceiveThisTokenByTrading();
    error InsufficientTokensToTransfer();
//Burn Error Validations
    error CanNotBurnThisToken();

contract ContractUtil is Ownable {

    ERC1155BaseContract internal baseContract;

    mapping(uint256 => bool) internal tokenValidationMap;
    mapping(uint256 => uint256[]) internal tokenForgeEligibilityMap;
    // token fees will be stored in ^14 decimal place
    mapping(uint256 => uint256) internal tokenFees;

    constructor(ERC1155BaseContract initBaseContract){
        baseContract = initBaseContract;
    }


    //--------------------------------------------------Setup Funtions  ---------------------------------------------

    function setInitialTokenURI() external onlyOwner {
        baseContract.setNewToken(0, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/0");
        baseContract.setNewToken(1, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/1");
        baseContract.setNewToken(2, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/2");
        baseContract.setNewToken(3, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/3");
        baseContract.setNewToken(4, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/4");
        baseContract.setNewToken(5, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/5");
        baseContract.setNewToken(6, "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/6");
        setEligibilityForMint();
        setEligibleTokenIds();
        setInitialFees();

    }

    function setEligibilityForMint() private {
        tokenForgeEligibilityMap[3] = [0, 1];
        tokenForgeEligibilityMap[4] = [1, 2];
        tokenForgeEligibilityMap[5] = [0, 2];
        tokenForgeEligibilityMap[6] = [0, 1, 2];
    }

    function setInitialFees() private {
        tokenFees[0] = 0;
        tokenFees[1] = 0;
        tokenFees[2] = 0;
        tokenFees[3] = 1 * 10 ** 14;
        tokenFees[4] = 1 * 10 ** 14;
        tokenFees[5] = 1 * 10 ** 14;
        tokenFees[6] = 1 * 10 ** 14;
    }


    function setEligibleTokenIds() private {
        tokenValidationMap[0] = true;
        tokenValidationMap[1] = true;
        tokenValidationMap[2] = true;
        tokenValidationMap[3] = true;
        tokenValidationMap[4] = true;
        tokenValidationMap[5] = true;
        tokenValidationMap[6] = true;
    }
    //------------------------------Util functions -----------------------------------------------------------


    function isAmountZero(uint256 amount) internal pure {
        if (amount == 0) {
            revert TokenAmountCanNotBeZero();
        }
    }

    function checkIfTransferTokenAreSame(uint256 from, uint256 to) internal pure {
        if (from == to) {
            revert TokenCanNotBeTradedForEqualTokenId();
        }
    }


    function getMiningPriceForToken(uint256 tokenId) public view returns (uint256 price) {
      
            price= tokenFees[tokenId];
       
       
    }


    function authorizeAddress(address sender) internal view {
        if (sender == address(0) || sender.code.length > 0) {
            revert InvalidWalletAddress();
        }
    }

    function checkIfTokenIsValid(uint256 tokenId) internal view{
        if (!tokenValidationMap[tokenId]) {
            revert TokenDoesNotExist();
        }
    }


}
