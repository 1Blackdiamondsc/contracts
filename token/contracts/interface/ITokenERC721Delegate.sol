pragma solidity ^0.8.0;

import "../interface/ITokenStorage.sol";


/**
 * @title Token Delegate ERC721 Interface
 * @dev Token Delegate ERC721 Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ITokenERC721Delegate is ITokenStorage {

  // IERC721 Metadata
  function tokenURI(uint256 tokenId) external view returns (string memory);
  function defineTemplateURI(address _tokem, string memory _baseURI, string memory _suffixURI) external;

  // IERC721 Enumerable
  function totalSupply() external view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index)
    external view returns (uint256 tokenId);
  function tokenByIndex(uint256 index) external view returns (uint256);

  // IERC721
  function balanceOf(address _owner) external view returns (uint256 balance);
  function ownerOf(uint256 _tokenId) external view returns (address owner);

  function transferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId) external;
  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId) external;
  function safeTransferFrom(
    address _caller,
    address _sender,
    address _receiver,
    uint256 _tokenId,
    bytes calldata data) external;

  function approve(address _approved, uint256 _tokenId) external;
  function getApproved(uint256 _tokenId) external view returns (address operator);
  function setApprovalForAll(address _operator, bool _approved) external;
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);

  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _tokenId) external view returns (TransferCode);
  function checkConfigurations(uint256[] calldata _auditConfigurationIds)
    external view returns (bool);
}
