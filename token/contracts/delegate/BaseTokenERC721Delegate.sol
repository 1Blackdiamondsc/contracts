pragma solidity ^0.8.0;

import "@c-layer/common/contracts/Account.sol";
import "@c-layer/common/contracts/convert/Bytes32Convert.sol";
import "@c-layer/common/contracts/interface/IERC721TokenReceiver.sol";
import "../interface/ITokenERC721Delegate.sol";
import "./STransferData.sol";
import "../TokenStorage.sol";
import "../interface/ITokenERC721Proxy.sol";


/**
 * @title Base Token Delegate ERC721
 * @dev Base Token Delegate ERC721
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   TDN01: Token does not exist
 *   TDN02: Recipient is invalid
 *   TDN03: The approver must either be the owner or the operator
 *   TDN04: The token sender is not the owner
 *   TDN05: The sender must either be the owner, the operator or the approvee
 *   TDN06: The receiver callback was unsuccessfull
 */
contract BaseTokenERC721Delegate is ITokenERC721Delegate, TokenStorage {
  using Account for address;
  using Bytes32Convert for bytes32;

  bytes4 internal constant RECEIVER_CALLBACK_SUCCESS =
    bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

  function tokenURI(uint256 _indexId) external override view returns (string memory) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    return string(abi.encodePacked(token.erc721.baseURI, bytes32(_indexId).toString(), token.erc721.suffixURI));
  }

  // IERC721 Enumerable
  function totalSupply() external override view returns (uint256) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    return token.totalSupply;
  }

  function tokenOfOwnerByIndex(address _owner, uint256 _index)
    external override view returns (uint256 tokenId)
  {
    TokenData storage token = tokens[IProxy(msg.sender)];
    tokenId = token.erc721.tokenIds[_index];
    tokenExistsInternal(tokenId);
    require(_owner != address(0), "TDN02");
    return token.erc721.owners[_owner].ownedTokenIds[_index];
  }

  function tokenByIndex(uint256 _index) external override view returns (uint256 tokenId) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    tokenId = token.erc721.tokenIds[_index];
    tokenExistsInternal(tokenId);
  }

  // IERC721
  function balanceOf(address _owner) external override view returns (uint256 balance) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    require(_owner != address(0), "TN02");
    return token.balances[_owner];
  }

  function ownerOf(uint256 _tokenId) external override view returns (address owner) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    owner = token.erc721.ownersAddresses[_tokenId];
    require(owner != address(0), "TN02");
  }

  function getApproved(uint256 _tokenId) external override view returns (address operator) {
    TokenData storage token = tokens[IProxy(msg.sender)];
    tokenExistsInternal(_tokenId);
    return token.erc721.approveds[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator)
    external override view returns (bool)
  {
    TokenData storage token = tokens[IProxy(msg.sender)];
    return token.erc721.operators[_owner][_operator];
  }

  function defineTemplateURI(address _token, string memory _baseURI, string memory _suffixURI)
    external override
  {
    TokenData storage token = tokens[IProxy(_token)];
    token.erc721.baseURI = _baseURI;
    token.erc721.suffixURI = _suffixURI;
    emit ERC721TemplateURIUpdated(_baseURI, _suffixURI);
  }

  function transferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId)
    external override
  {
    transferFromInternal(
      transferData(IProxy(msg.sender), _caller, _sender, _receiver, _tokenId));
  }

  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId)
    external override
  {
    transferFromInternal(
      transferData(IProxy(msg.sender), _caller, _sender, _receiver, _tokenId));
    receiverCallbackInternal(_sender, _receiver, _tokenId, "");
  }

  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId, bytes calldata _data)
    external override
  {
    transferFromInternal(
      transferData(IProxy(msg.sender), _caller, _sender, _receiver, _tokenId));
    receiverCallbackInternal(_sender, _receiver, _tokenId, _data);
  }

  function approve(address _approved, uint256 _tokenId) external override {
    TokenData storage token = tokens[IProxy(msg.sender)];
    require(token.erc721.ownersAddresses[_tokenId] == msg.sender
      || token.erc721.operators[_approved][msg.sender], "TDN03");
    token.erc721.approveds[_tokenId] = _approved;

    require(
      ITokenERC721Proxy(msg.sender).emitApproval(msg.sender, _approved, _tokenId),
      "TDNXX");
  }

  function setApprovalForAll(address _operator, bool _approved)
    external override
  {
    TokenData storage token = tokens[IProxy(msg.sender)];
    token.erc721.operators[msg.sender][_operator] = _approved;

    require(
      ITokenERC721Proxy(msg.sender).emitApprovalForAll(msg.sender, _operator, _approved),
      "TDNXX");
  }

  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _tokenId) virtual public override view returns (TransferCode) {
    return canTransferInternal(
      transferData(IProxy(msg.sender), address(0), _sender, _receiver, _tokenId));
  }

  function checkConfigurations(uint256[] calldata)
    public override pure returns (bool) {
    return true;
  }

  function canTransferInternal(STransferData memory _transferData)
    virtual internal view returns (TransferCode)
  {
    TokenData storage token = tokens[_transferData.token];
    address sender = _transferData.sender;
    address receiver = _transferData.receiver;
    uint256 tokenId = _transferData.tokenId;

    if (sender == address(0)) {
      return TransferCode.INVALID_SENDER;
    }

    if (receiver == address(0)) {
      return TransferCode.NO_RECIPIENT;
    }

    // FIXME: check on tokenId validity
    if (tokenId > token.balances[sender]) {
      return TransferCode.UNKNOWN;
    }

    return TransferCode.OK;
  }

  function tokenExistsInternal(uint256 _tokenId) internal view {
    // FIXME msg.sender is not the caller
    TokenData storage token = tokens[IProxy(msg.sender)];
    require(token.erc721.ownersAddresses[_tokenId] != address(0), "TDN01");
  }

  function transferFromInternal(STransferData memory _transferData)
    internal
  {
    TokenData storage token = tokens[IProxy(_transferData.caller)];
    tokenExistsInternal(_transferData.tokenId);
    require(_transferData.receiver != address(0), "TDN02");
    require(token.erc721.ownersAddresses[_transferData.tokenId] == _transferData.sender, "TDN04");

    require(_transferData.sender == _transferData.caller ||
      token.erc721.approveds[_transferData.tokenId] == _transferData.caller ||
      token.erc721.operators[_transferData.sender][_transferData.caller], "TDN05");

    token.erc721.ownersAddresses[_transferData.tokenId] = _transferData.receiver;

    OwnerERC721 storage from = token.erc721.owners[_transferData.sender];
    token.balances[_transferData.sender]--;
    from.ownedTokenIds[from.ownedTokenIndexes[_transferData.tokenId]] =
      from.ownedTokenIds[token.balances[_transferData.sender]];
    from.ownedTokenIds[token.balances[_transferData.sender]] = 0;

    OwnerERC721 storage to = token.erc721.owners[_transferData.receiver];
    to.ownedTokenIds[token.balances[_transferData.receiver]] = _transferData.tokenId;
    to.ownedTokenIndexes[_transferData.tokenId] = token.balances[_transferData.receiver];
    token.balances[_transferData.receiver]++;

    require(
      ITokenERC721Proxy(msg.sender).emitTransfer(
        _transferData.sender,
        _transferData.receiver,
        _transferData.tokenId),
      "TDNXX");
  }

  function receiverCallbackInternal(address _from, address _to, uint256 _tokenId, bytes memory _data)
    internal
  {
    if(_to.isContract()) {
      require(IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)
        == RECEIVER_CALLBACK_SUCCESS, "TDN06");
    }
  }

  function transferData(
    IProxy _token, address _caller,
    address _sender, address _receiver, uint256 _tokenId)
    internal pure returns (STransferData memory)
  {
    uint256[] memory emptyArray = new uint256[](1);

    return STransferData(
      _token,
      _caller,
      _sender,
      _receiver,
      0,
      emptyArray,
      false,
      0,
      emptyArray,
      false,
      0,
      _tokenId,
      0
    );
  }
}
