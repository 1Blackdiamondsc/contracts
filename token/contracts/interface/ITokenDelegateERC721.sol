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
abstract contract ITokenDelegateERC721 is ITokenStorage {

  // IERC721 Metadata
  function tokenURI(uint256 tokenId) external virtual view returns (string memory);
  function defineTemplateURI(address _tokem, string memory _baseURI, string memory _suffixURI) external virtual;

  // IERC721 Enumerable
  function totalSupply() external virtual view returns (uint256);
  function tokenOfOwnerByIndex(address owner, uint256 index)
    external virtual view returns (uint256 tokenId);
  function tokenByIndex(uint256 index) external virtual view returns (uint256);

  // IERC721
  function balanceOf(address _owner) external virtual view returns (uint256 balance);
  function ownerOf(uint256 _tokenId) external virtual view returns (address owner);

  function transferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId) external virtual;
  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId) external virtual;
  function safeTransferFrom(
    address _caller,
    address _sender,
    address _receiver,
    uint256 _tokenId,
    bytes calldata data) external virtual;

  function approve(address _approved, uint256 _tokenId) external virtual;
  function getApproved(uint256 _tokenId) external virtual view returns (address operator);
  function setApprovalForAll(address _operator, bool _approved) external virtual;
  function isApprovedForAll(address _owner, address _operator) external virtual view returns (bool);

  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _tokenId) virtual public view returns (TransferCode);
  function checkConfigurations(uint256[] calldata _auditConfigurationIds)
    virtual public view returns (bool);
}
