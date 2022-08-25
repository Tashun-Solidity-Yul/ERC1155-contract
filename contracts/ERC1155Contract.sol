// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./utils/ContractUtil.sol";

// todo need to handle safe math and transfer

contract ERC1155Contract is ERC1155, ContractUtil {
    event ActionNotifier(address observer);

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
        emit ActionNotifier(msg.sender);
    }

    function startBurningToken(uint256 tokenId, uint256 amount) external payable {
        // check if the tokens are among 0,1,2,3,4,5,6
        checkIfTokenIsValid(tokenId);
        // amount can not be zero
        isAmountZero(amount);
        // check availabilities
        isEligibleToBurn(tokenId, amount);
        // restrict null address and contract Addresses
        authorizeAddress(msg.sender);
        // burn tokens
        _burn(msg.sender, tokenId, amount);
        emit ActionNotifier(msg.sender);
    }

    function startTransferringToken(uint256 fromTokenId, uint256 toTokenId, uint256 amount) external payable {
        require(fromTokenId != toTokenId, "Invalid Transfer");
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
        _burn(msg.sender, fromTokenId, amount);
        _mint(msg.sender, toTokenId, amount, "");
        emit ActionNotifier(msg.sender);
    }


    function forgeOrMintTokens(uint256 tokenId, uint256 amount) private {
        if (tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) {
            burnTokensInForgingProcess(tokenId, amount);
        }
        _mint(msg.sender, tokenId, amount, "");
    }

    function burnTokensInForgingProcess(uint256 tokenId, uint256 amount) private {
        for (uint256 _index = 0; _index < tokenForgeEligibilityMap[tokenId].length; _index++) {
            _burn(msg.sender, tokenForgeEligibilityMap[tokenId][_index], amount);
        }
    }

    /**
        Tokens 0,1,2 can be minted without restrictions
        To mint token 3
    */
    function isEligibleToMintTokenId(uint256 tokenId, uint256 amount) internal returns (bool isEligible){
        isEligible = false;
        if (tokenId == 0 || tokenId == 1 || tokenId == 2) {
            isEligible = true;
        }
        else if (tokenId == 3) {
            require(balanceOf(msg.sender, 0) > amount - 1, "Missing a Token Zero");
            require(balanceOf(msg.sender, 1) > amount - 1, "Missing a Token One");
            isEligible = true;
        }
        else if (tokenId == 4) {
            require(balanceOf(msg.sender, 1) > amount - 1, "Missing a Token One");
            require(balanceOf(msg.sender, 2) > amount - 1, "Missing a Token Two");
            isEligible = true;
        }
        else if (tokenId == 5) {
            require(balanceOf(msg.sender, 0) > amount - 1, "Missing a Token Zero");
            require(balanceOf(msg.sender, 2) > amount - 1, "Missing a Token Two");
            isEligible = true;
        }
        else if (tokenId == 6) {
            require(balanceOf(msg.sender, 0) > amount - 1, "Missing a Token Zero");
            require(balanceOf(msg.sender, 1) > amount - 1, "Missing a Token One");
            require(balanceOf(msg.sender, 2) > amount - 1, "Missing a Token Two");
            isEligible = true;
        }

    }

    function isEligibleToBurn(uint256 tokenId, uint256 amount) internal returns (bool isEligible){
        isEligible = false;
        require(tokenId != 0, "Can not burn this token");
        require(tokenId != 1, "Can not burn this token");
        require(tokenId != 2, "Can not burn this token");
        if ((tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) && amount > 0) {
            require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient Tokens to burn");
            isEligible = true;
        }

    }

    function isEligibleToTransfer(uint256 tokenId, uint256 amount, bool isFromToken) internal returns (bool isEligible){
        // transfers can only be one to one 
        isEligible = false;
        if (!isFromToken) {
            require(tokenId != 3, "Can not Trade For token 3");
            require(tokenId != 4, "Can not Trade For token 4");
            require(tokenId != 5, "Can not Trade For token 5");
            require(tokenId != 6, "Can not Trade For token 6");
        }
        if ((tokenId == 0 || tokenId == 1 || tokenId == 2 || tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) && amount > 0 && isFromToken) {
            require(balanceOf(msg.sender, tokenId) >= amount, "Insufficient Tokens to Transfer");
            isEligible = true;
        } else if ((tokenId == 0 || tokenId == 1 || tokenId == 2) && !isFromToken) {
            isEligible = true;
        }

    }

    function getAllTokenBalances(address userAddress) external view returns (uint[] memory){
        uint[] memory userBalances = new uint[](7);
        userBalances[0] = balanceOf(userAddress, 0);
        userBalances[1] = balanceOf(userAddress, 1);
        userBalances[2] = balanceOf(userAddress, 2);
        userBalances[3] = balanceOf(userAddress, 3);
        userBalances[4] = balanceOf(userAddress, 4);
        userBalances[5] = balanceOf(userAddress, 5);
        userBalances[6] = balanceOf(userAddress, 6);
        return userBalances;
    }

}
