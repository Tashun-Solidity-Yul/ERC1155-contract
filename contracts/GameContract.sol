// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC1155BaseContract.sol";
// General Error Validations
error TokenDoesNotExist();
error InvalidWalletAddress();
error TokenAmountCanNotBeZero();
error InsufficientTokens();

// Minting and Forging Error Validations
error InSufficientMatic();
error MintingTooFast();

// Trade errors
error TokenCanNotBeTradedForEqualTokenId();
error CanNotReceiveThisTokenByTrading();
error InsufficientTokensToTransfer();
//Burn Error Validations
error CanNotBurnThisToken();

// todo add cool down
contract GameContract is Ownable {
    using Strings for uint256;
    ERC1155BaseContract internal baseContract;

    string private ipfsFolder =
        "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/";

    uint256 private immutable secondsForAMinute = 1 minutes;

    mapping(uint256 => bool) private tokenValidationMap;
    mapping(uint256 => uint256[]) private tokenForgeEligibilityMap;
    // token fees will be stored in ^14 decimal place
    mapping(uint256 => uint256) private tokenFees;
    mapping(address => uint256) private coolDownMap;

    event MintBurnTradeNotifier(address observer);

    constructor(ERC1155BaseContract initBaseContract) {
        baseContract = initBaseContract;
    }

    /**
        tokenId - token Id user would like to mint/forge
        amount - unit of token Ids user would like to mint/forge
    */
    function startMintingToken(uint256 tokenId, uint256 amount)
        external
        payable
    {
        if (coolDownMap[msg.sender] + secondsForAMinute > block.timestamp) {
            revert MintingTooFast();
        }
        // check if the tokens are among 0,1,2,3,4,5,6
        checkIfTokenIsValid(tokenId);
        // amount can not be zero
        isAmountZero(amount);
        // implement the token dependency logic
        isEligibleToMintTokenId(tokenId, amount);
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
        // burn tokens
        baseContract.burnToken(msg.sender, tokenId, amount);
        emit MintBurnTradeNotifier(msg.sender);
    }

    function startTransferringToken(
        uint256 fromTokenId,
        uint256 toTokenId,
        uint256 amount
    ) external {
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
        // burn tokens
        baseContract.burnToken(msg.sender, fromTokenId, amount);
        baseContract.mintToken(msg.sender, toTokenId, amount);
        emit MintBurnTradeNotifier(msg.sender);
    }

    function balanceOf(address account, uint256 tokenId)
        external
        view
        returns (uint256 returningBalance)
    {
        returningBalance = baseContract.balanceOf(account, tokenId);
    }

    //--------------------------------------------------Setup Funtions  ---------------------------------------------

    function setInitialTokenURI() external onlyOwner {
        for (uint256 i = 0; i < 7; i++) {
            baseContract.setNewToken(
                i,
                string(abi.encodePacked(ipfsFolder, i.toString()))
            );
        }
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
        tokenFees[3] = 1 * 10**14;
        tokenFees[4] = 1 * 10**14;
        tokenFees[5] = 1 * 10**14;
        tokenFees[6] = 1 * 10**14;
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

    function isAmountZero(uint256 amount) private pure {
        if (amount == 0) {
            revert TokenAmountCanNotBeZero();
        }
    }

    function checkIfTransferTokenAreSame(uint256 from, uint256 to)
        private
        pure
    {
        if (from == to) {
            revert TokenCanNotBeTradedForEqualTokenId();
        }
    }

    function getMiningPriceForToken(uint256 tokenId)
        public
        view
        returns (uint256 price)
    {
        price = tokenFees[tokenId];
    }

    function checkIfTokenIsValid(uint256 tokenId) private view {
        if (!tokenValidationMap[tokenId]) {
            revert TokenDoesNotExist();
        }
    }

    //    --------------------------------------- Game contract Logic functions --------------------------
    function forgeOrMintTokens(uint256 tokenId, uint256 amount) private {
        if (tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) {
            burnTokensInForgingProcess(tokenId, amount);
        }
        baseContract.mintToken(msg.sender, tokenId, amount);
        coolDownMap[msg.sender] = block.timestamp;
        emit MintBurnTradeNotifier(msg.sender);
    }

    function burnTokensInForgingProcess(uint256 tokenId, uint256 amount)
        private
    {
        for (
            uint256 _index = 0;
            _index < tokenForgeEligibilityMap[tokenId].length;
            _index++
        ) {
            baseContract.burnToken(
                msg.sender,
                tokenForgeEligibilityMap[tokenId][_index],
                amount
            );
        }
    }

    /**
        Tokens 0,1,2 can be minted without restrictions
        To mint token 3
    */
    function isEligibleToMintTokenId(uint256 tokenId, uint256 amount)
        private
        view
        returns (bool isEligible)
    {
        isEligible = false;
        if (tokenId == 0 || tokenId == 1 || tokenId == 2) {
            isEligible = true;
        } else if (tokenId == 3) {
            require(
                baseContract.balanceOf(msg.sender, 0) > amount - 1,
                "Missing a Token Zero"
            );
            require(
                baseContract.balanceOf(msg.sender, 1) > amount - 1,
                "Missing a Token One"
            );
            isEligible = true;
        } else if (tokenId == 4) {
            require(
                baseContract.balanceOf(msg.sender, 1) > amount - 1,
                "Missing a Token One"
            );
            require(
                baseContract.balanceOf(msg.sender, 2) > amount - 1,
                "Missing a Token Two"
            );
            isEligible = true;
        } else if (tokenId == 5) {
            require(
                baseContract.balanceOf(msg.sender, 0) > amount - 1,
                "Missing a Token Zero"
            );
            require(
                baseContract.balanceOf(msg.sender, 2) > amount - 1,
                "Missing a Token Two"
            );
            isEligible = true;
        } else {
            require(
                baseContract.balanceOf(msg.sender, 0) > amount - 1,
                "Missing a Token Zero"
            );
            require(
                baseContract.balanceOf(msg.sender, 1) > amount - 1,
                "Missing a Token One"
            );
            require(
                baseContract.balanceOf(msg.sender, 2) > amount - 1,
                "Missing a Token Two"
            );
            isEligible = true;
        }
    }

    function isEligibleToBurn(uint256 tokenId, uint256 amount)
        private
        view
        returns (bool isEligible)
    {
        isEligible = false;
        if (tokenId == 0) {
            revert CanNotBurnThisToken();
        } else if (tokenId == 1) {
            revert CanNotBurnThisToken();
        } else if (tokenId == 2) {
            revert CanNotBurnThisToken();
        } else {
            if (baseContract.balanceOf(msg.sender, tokenId) < amount) {
                revert InsufficientTokens();
            }
            isEligible = true;
        }
    }

    function isEligibleToTransfer(
        uint256 tokenId,
        uint256 amount,
        bool isFromToken
    ) private view returns (bool isEligible) {
        // transfers can only be one to one
        isEligible = false;
        if (!isFromToken) {
            if (tokenId == 3) {
                revert CanNotReceiveThisTokenByTrading();
            }
            if (tokenId == 4) {
                revert CanNotReceiveThisTokenByTrading();
            }
            if (tokenId == 5) {
                revert CanNotReceiveThisTokenByTrading();
            }
            if (tokenId == 6) {
                revert CanNotReceiveThisTokenByTrading();
            }
        }
        if (
            (tokenId == 0 ||
                tokenId == 1 ||
                tokenId == 2 ||
                tokenId == 3 ||
                tokenId == 4 ||
                tokenId == 5 ||
                tokenId == 6) &&
            amount > 0 &&
            isFromToken
        ) {
            if (baseContract.balanceOf(msg.sender, tokenId) < amount) {
                revert InsufficientTokensToTransfer();
            }
            isEligible = true;
        } else {
            isEligible = true;
        }
    }
}
