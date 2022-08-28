// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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
//Burn Error Validations
    error CanNotBurnThisToken();

contract ContractUtil {
    string internal initialURI = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/0";
    mapping(uint256 => string) internal tokenMap;
    mapping(uint256 => bool) internal tokenValidationMap;
    mapping(uint256 => uint256[]) internal tokenForgeEligibilityMap;
    // token fees will be stored in ^14 decimal place
    mapping(uint256 => uint256[]) internal tokenFees;

    constructor(){
        setEligibleTokenURI();
        setEligibilityForMint();
        setEligibleTokenIds();
        setInitialFees();
    }

    function checkIfTokenIsValid(uint256 tokenId) internal view returns (string memory isValid){
        isValid = tokenMap[tokenId];
    }

    function getMiningPriceForToken(uint256 tokenId) internal pure returns (uint256 price) {
        if (tokenFees[tokenId]) {
            return tokenFees[tokenId];
        }
        revert TokenDoesNotExist();
    }

    function setInitialFees(uint256 tokenId, uint256 fee) internal {
        tokenFees[0] = 0;
        tokenFees[1] = 0;
        tokenFees[2] = 0;
        tokenFees[3] = 1 * 10 ** 14;
        tokenFees[4] = 1 * 10 ** 14;
        tokenFees[5] = 1 * 10 ** 14;
        tokenFees[6] = 1 * 10 ** 14;
    }

    function authorizeAddress(address sender) internal view {
        if (sender == address(0) || sender.code.length > 0) {
            revert InvalidWalletAddress();
        }
    }

    function setEligibilityForMint() internal {
        tokenForgeEligibilityMap[3] = [0, 1];
        tokenForgeEligibilityMap[4] = [1, 2];
        tokenForgeEligibilityMap[5] = [0, 2];
        tokenForgeEligibilityMap[6] = [0, 1, 2];
    }


    function setEligibleTokenURI() private {
        tokenMap[0] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/0";
        tokenMap[1] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/1";
        tokenMap[2] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/2";
        tokenMap[3] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/3";
        tokenMap[4] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/4";
        tokenMap[5] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/5";
        tokenMap[6] = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/6";
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

    function isAmountZero(uint256 amount) internal pure {
        if (amount == 0) {
            revert TokenAmountCanNotBeZero();
        }
    }

    function checkIfTransferTokenAreSame(uint256 from, uint256 to){
        if (from == to) {
            revert TokenCanNotBeTradedForEqualTokenId();
        }
    }


}
