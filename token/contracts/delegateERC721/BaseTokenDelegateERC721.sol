pragma solidity ^0.8.0;

import "@c-layer/common/contracts/Account.sol";
import "@c-layer/common/contracts/convert/Bytes32Convert.sol";
import "@c-layer/common/contracts/interface/IERC721TokenReceiver.sol";
import "../interface/ITokenDelegateERC721.sol";
import "./STransferDataERC721.sol";
import "../TokenStorage.sol";
import "../interface/ITokenProxyERC721.sol";


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
contract BaseTokenDelegateERC721 is ITokenDelegateERC721, TokenStorage {
  using Account for address;
  using Bytes32Convert for bytes32;

  bytes4 internal constant RECEIVER_CALLBACK_SUCCESS =
    bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

  function tokenURI(uint256 _indexId) external override view returns (string memory) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    return string(abi.encodePacked(token.baseURI, bytes32(_indexId).toString(), token.suffixURI));
  }

  // IERC721 Enumerable
  function totalSupply() external override view returns (uint256) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    return token.totalSupply;
  }

  function tokenOfOwnerByIndex(address _owner, uint256 _index)
    external override view returns (uint256 _tokenId)
  {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    uint256 tokenId = token.tokenIds[_index];
    tokenExistsInternal(_tokenId);
    require(_owner != address(0), "TDN02");
    return token.owners[_owner].ownedTokenIds[_index];
  }

  function tokenByIndex(uint256 _index) external override view returns (uint256) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    uint256 tokenId = token.tokenIds[_index];
    tokenExistsInternal(tokenId);
    return tokenId;
  }

  // IERC721
  function balanceOf(address _owner) external override view returns (uint256 balance) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    require(_owner != address(0), "TN02");
    return token.owners[_owner].balance;
  }

  function ownerOf(uint256 _tokenId) external override view returns (address owner) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    owner = token.ownersAddresses[_tokenId];
    require(owner != address(0), "TN02");
  }

  function getApproved(uint256 _tokenId) external override view returns (address operator) {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    tokenExistsInternal(_tokenId);
    return token.approveds[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator)
    external override view returns (bool)
  {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    return token.operators[_owner][_operator];
  }

  function defineTemplateURI(address _token, string memory _baseURI, string memory _suffixURI)
    external override
  {
    TokenDataERC721 storage token = tokenERC721s[_token];
    token.baseURI = _baseURI;
    token.suffixURI = _suffixURI;
    emit TemplateURIUpdated(_baseURI, _suffixURI);
  }

  function transferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId)
    external override
  {
    transferFromInternal(
      transferData(msg.sender, _caller, _sender, _receiver, _tokenId));
  }

  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId)
    external override
  {
    transferFromInternal(
      transferData(msg.sender, _caller, _sender, _receiver, _tokenId));
    receiverCallbackInternal(_sender, _receiver, _tokenId, "");
  }

  function safeTransferFrom(address _caller, address _sender, address _receiver, uint256 _tokenId, bytes calldata _data)
    external override
  {
    transferFromInternal(
      transferData(msg.sender, _caller, _sender, _receiver, _tokenId));
    receiverCallbackInternal(_sender, _receiver, _tokenId, _data);
  }

  function approve(address _approved, uint256 _tokenId) external override {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    require(token.ownersAddresses[_tokenId] == msg.sender
      || token.operators[_approved][msg.sender], "TDN03");
    token.approveds[_tokenId] = _approved;

    require(
      ITokenProxyERC721(msg.sender).emitApproval(msg.sender, _approved, _tokenId),
      "TDNXX");
  }

  function setApprovalForAll(address _operator, bool _approved)
    external override
  {
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    token.operators[msg.sender][_operator] = _approved;

    require(
      ITokenProxyERC721(msg.sender).emitApprovalForAll(msg.sender, _operator, _approved),
      "TDNXX");
  }

  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _tokenId) virtual public override view returns (TransferCode) {
    return canTransferInternal(
      transferData(msg.sender, address(0), _sender, _receiver, _tokenId));
  }

  function checkConfigurations(uint256[] calldata _auditConfigurationIds)
    public override view returns (bool) {
    return true;
  }

  function canTransferInternal(STransferDataERC721 memory _transferData)
    virtual internal view returns (TransferCode)
  {
    TokenDataERC721 storage token = tokenERC721s[_transferData.token];
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
    if (tokenId > token.owners[sender].balance) {
      return TransferCode.UNKNOWN;
    }

    return TransferCode.OK;
  }

  function tokenExistsInternal(uint256 _tokenId) internal view {
    // FIXME msg.sender is not the caller
    TokenDataERC721 storage token = tokenERC721s[msg.sender];
    require(token.ownersAddresses[_tokenId] != address(0), "TDN01");
  }

  function transferFromInternal(STransferDataERC721 memory _transferData)
    internal
  {
    TokenDataERC721 storage token = tokenERC721s[_transferData.caller];
    tokenExistsInternal(_transferData.tokenId);
    require(_transferData.receiver != address(0), "TDN02");
    require(token.ownersAddresses[_transferData.tokenId] == _transferData.sender, "TDN04");

    require(_transferData.sender == _transferData.caller ||
      token.approveds[_transferData.tokenId] == _transferData.caller ||
      token.operators[_transferData.sender][_transferData.caller], "TDN05");

    token.ownersAddresses[_transferData.tokenId] = _transferData.receiver;

    OwnerERC721 storage from = token.owners[_transferData.sender];
    from.ownedTokenIds[from.ownedTokenIndexes[_transferData.tokenId]] =
      from.ownedTokenIds[from.balance-1];
    from.ownedTokenIds[from.balance-1] = 0;
    from.balance--;

    OwnerERC721 storage to = token.owners[_transferData.receiver];
    to.ownedTokenIds[to.balance] = _transferData.tokenId;
    to.ownedTokenIndexes[_transferData.tokenId] = to.balance;
    to.balance++;

    require(
      ITokenProxyERC721(msg.sender).emitTransfer(
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
    address _token, address _caller,
    address _sender, address _receiver, uint256 _tokenId)
    internal pure returns (STransferDataERC721 memory)
  {
    uint256[] memory emptyArray = new uint256[](1);
    return STransferDataERC721(
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
        _tokenId,
        0
    );
  }
}
