pragma solidity ^0.8.0;

import "@c-layer/common/contracts/call/DelegateCall.sol";
import "@c-layer/common/contracts/core/OperableProxy.sol";
import "./interface/ITokenERC721Proxy.sol";
import "./interface/ITokenCore.sol";
import "./interface/ITokenERC721Delegate.sol";


/**
 * @title Token proxy
 * @dev Token proxy default implementation
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
contract TokenERC721Proxy is ITokenERC721Proxy, OperableProxy {
  using DelegateCall for address;

  // solhint-disable-next-line no-empty-blocks
  constructor(ITokenCore _core) OperableProxy(_core) { }

  function interface165() external pure returns (bytes4) {
    return type(IERC721Enumerable).interfaceId;
  }

  function interface721() external pure returns (bytes4) {
    return type(IERC721Metadata).interfaceId;
  }

  function supportsInterface(bytes4 _interfaceId) external pure override returns (bool) {
    return _interfaceId == type(IERC165).interfaceId
      || _interfaceId == type(IERC721).interfaceId
      || _interfaceId == type(IERC721Enumerable).interfaceId
      || _interfaceId == type(IERC721Metadata).interfaceId;
  }

  function name() override external view returns (string memory) {
    return staticCallString();
  }

  function symbol() override external view returns (string memory) {
    return staticCallString();
  }

  function totalSupply() override external view returns (uint256) {
    return staticCallUint256();
  }

  function tokenURI(uint256) external override view returns (string memory) {
    return staticCallString();
  }

  function tokenByIndex(uint256) external override view returns (uint256) {
    return staticCallUint256();
  }

  function balanceOf(address) override external view returns (uint256) {
    return staticCallUint256();
  }

  function tokenOfOwnerByIndex(address, uint256) external override view returns (uint256) {
    return staticCallUint256();
  }

  function ownerOf(uint256) external override view returns (address) {
    return abi.decode(address(core)._forwardStaticCall(msg.data), (address));
  }

  function getApproved(uint256 _tokenId)
    external override view returns (address)
  {
    return ITokenERC721Delegate(address(core)).getApproved(_tokenId);
  }

  function isApprovedForAll(address _owner, address _operator)
    external override view returns (bool)
  {
    return ITokenERC721Delegate(address(core)).isApprovedForAll(_owner, _operator);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external override
  {
    ITokenERC721Delegate(address(core)).transferFrom(msg.sender, _from, _to, _tokenId);
  }

  function approve(address _approved, uint256 _tokenId) external override
  {
    ITokenERC721Delegate(address(core)).approve(_approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved)
    external override
  {
    ITokenERC721Delegate(address(core)).setApprovalForAll(_operator, _approved);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    external override
  {
    ITokenERC721Delegate(address(core)).safeTransferFrom(msg.sender, _from, _to, _tokenId);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data)
    external override
  {
    ITokenERC721Delegate(address(core)).safeTransferFrom(msg.sender, _from, _to, _tokenId, _data);
  }

  function canTransfer(address, address, uint256)
    external override view returns (uint256)
  {
    return staticCallUint256();
  }

  function emitTransfer(address _from, address _to, uint256 _value)
    override external onlyCore returns (bool)
  {
    emit Transfer(_from, _to, _value);
    return true;
  }

  function emitApproval(address _owner, address _spender, uint256 _value)
    external override onlyCore returns (bool)
  {
    emit Approval(_owner, _spender, _value);
    return true;
  }

  function emitApprovalForAll(address _owner, address _operator, bool _approved)
    external override returns (bool)
  {
    emit ApprovalForAll(_owner, _operator, _approved);
    return true;
  }

}
