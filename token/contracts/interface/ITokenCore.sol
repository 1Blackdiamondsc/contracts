pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/ICore.sol";
import "@c-layer/common/contracts/interface/IProxy.sol";
import "./ITokenStorage.sol";


/**
 * @title ITokenCore
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 **/
interface ITokenCore is ITokenStorage, ICore {

  function name() external view returns (string memory);
  function oracle() external view returns (
    IUserRegistry userRegistry,
    IRatesProvider ratesProvider,
    address currency);

  function auditConfiguration(uint256 _configurationId)
    external view returns (
      uint256 scopeId,
      AuditTriggerMode _mode,
      uint256[] memory senderKeys,
      uint256[] memory receiverKeys,
      IRatesProvider ratesProvider,
      address currency);
  function auditTrigger(uint256 _configurationId, address _sender, address _receiver)
    external view returns (AuditTriggerMode);
  function delegatesConfigurations(uint256 _delegateId)
    external view returns (uint256[] memory);

  function auditCurrency(
    address _scope,
    uint256 _scopeId
  ) external view returns (address currency);
  function audit(
    address _scope,
    uint256 _scopeId,
    AuditStorageMode _storageMode,
    bytes32 _storageId) external view returns (
    uint64 createdAt,
    uint64 lastTransactionAt,
    uint256 cumulatedEmission,
    uint256 cumulatedReception);

  /************  CORE ADMIN  ************/
  function defineToken(
    IProxy _token,
    uint256 _delegateId,
    string memory _name,
    string memory _symbol,
    uint256 _decimals) external;

  function defineOracle(
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    address _currency) external;
  function defineTokenDelegate(
    uint256 _delegateId,
    address _delegate,
    uint256[] calldata _configurations) external;
  function defineAuditConfiguration(
    uint256 _configurationId,
    uint256 _scopeId,
    AuditTriggerMode _mode,
    uint256[] calldata _senderKeys,
    uint256[] calldata _receiverKeys,
    IRatesProvider _ratesProvider,
    address _currency) external;
  function removeAudits(address _scope, uint256 _scopeId) external;
  function defineAuditTriggers(
    uint256 _configurationId,
    address[] calldata _senders,
    address[] calldata _receivers,
    AuditTriggerMode[] calldata _modes) external;

  function isSelfManaged(address _owner) external view returns (bool);
  function manageSelf(bool _active) external;
}
