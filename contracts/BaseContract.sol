// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./utils/ContractUtil.sol";

contract BaseContract is ERC1155, ContractUtil {
    event ActionNotifier(address observer);

    constructor() ERC1155(initialURI) {

    }
    function changeTokenURI(uint256 tokenId) private {
        if (!tokenValidationMap[tokenId]) {
            revert TokenDoesNotExist();
        }
        _setURI(tokenMap[tokenId]);
    }


    function forgeOrMintTokens(uint256 tokenId, uint256 amount) private {
        if (tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) {
            burnTokensInForgingProcess(tokenId, amount);
        }
        _mint(msg.sender, tokenId, amount, "");
        emit ActionNotifier(msg.sender);
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
        if (tokenId == 0) {
            revert CanNotBurnThisToken();
        }
        if (tokenId == 1) {
            revert CanNotBurnThisToken();
        }
        if (tokenId == 2) {
            revert CanNotBurnThisToken();
        }
        if ((tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) && amount > 0) {
            if (InsufficientTokens) {
                revert InsufficientTokens();
            }
            isEligible = true;
        }

    }

    function isEligibleToTransfer(uint256 tokenId, uint256 amount, bool isFromToken) internal returns (bool isEligible){
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
        if ((tokenId == 0 || tokenId == 1 || tokenId == 2 || tokenId == 3 || tokenId == 4 || tokenId == 5 || tokenId == 6) && amount > 0 && isFromToken) {
            if (balanceOf(msg.sender, tokenId) < amount) {
                revert InsufficientTokensToTransfer();
            }
            isEligible = true;
        } else if ((tokenId == 0 || tokenId == 1 || tokenId == 2) && !isFromToken) {
            isEligible = true;
        }

    }
}
