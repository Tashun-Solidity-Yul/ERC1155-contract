// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
    error InvalidToken();

contract ERC1155BaseContract is ERC1155URIStorage, AccessControl {
    string internal initialURI = "ipfs://bafybeielsn64kfenijpqvmt5wx5vwmuhbsdbynquvjy2wswsxigpgtj2jq/0";
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(uint256 => bool) internal tokenValidationMap;

    constructor() ERC1155(initialURI){
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view override (AccessControl, ERC1155) returns (bool) {
        return
        interfaceId == type(IAccessControl).interfaceId ||
        interfaceId == type(IERC1155).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    function setNewToken(uint256 tokenId, string memory tokenURI) external onlyRole(ADMIN_ROLE) {
        if (tokenValidationMap[tokenId]) {
            revert InvalidToken();
        }
        tokenValidationMap[tokenId] = true;
        _setURI(tokenId, tokenURI);
    }

    function mintToken(address sender, uint256 tokenId, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _mint(sender, tokenId, amount, "");
    }

    function burnToken(address sender, uint256 tokenId, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _burn(sender, tokenId, amount);
    }

}
