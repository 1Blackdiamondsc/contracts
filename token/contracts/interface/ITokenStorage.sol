pragma solidity ^0.8.0;

import "@c-layer/oracle/contracts/interface/IUserRegistry.sol";
import "@c-layer/oracle/contracts/interface/IRatesProvider.sol";
import "./IRule.sol";


/**
 * @title ITokenStorage
 * @dev Token storage interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
abstract contract ITokenStorage {
  enum TransferCode {
    UNKNOWN,
    OK,
    INVALID_SENDER,
    NO_RECIPIENT,
    INSUFFICIENT_TOKENS,
    LOCKED,
    FROZEN,
    RULE,
    INVALID_RATE,
    NON_REGISTRED_SENDER,
    NON_REGISTRED_RECEIVER,
    LIMITED_EMISSION,
    LIMITED_RECEPTION
  }

  enum Scope {
    DEFAULT
  }

  enum AuditStorageMode {
    ADDRESS,
    USER_ID,
    SHARED
  }

  enum AuditTriggerMode {
    UNDEFINED,
    NONE,
    SENDER_ONLY,
    RECEIVER_ONLY,
    BOTH
  }

  address internal constant ANY_ADDRESSES = address(0x416e79416464726573736573); // "AnyAddresses"

  event OracleDefined(
    IUserRegistry userRegistry,
    IRatesProvider ratesProvider,
    address currency);
  event TokenDelegateDefined(uint256 indexed delegateId, address delegate, uint256[] configurations);
  event TokenDelegateRemoved(uint256 indexed delegateId);
  event AuditConfigurationDefined(
    uint256 indexed configurationId,
    uint256 scopeId,
    AuditTriggerMode mode,
    uint256[] senderKeys,
    uint256[] receiverKeys,
    IRatesProvider ratesProvider,
    address currency);
  event AuditTriggersDefined(
    uint256 indexed configurationId,
    address[] senders,
    address[] receivers,
    AuditTriggerMode[] modes);
  event AuditsRemoved(address scope, uint256 scopeId);
  event SelfManaged(address indexed holder, bool active);

  // ERC20
  event Minted(address indexed token, uint256 amount);
  event Burned(address indexed token, uint256 amount);
  event Seize(address indexed token, address account, uint256 amount);

  // ERC721
  event TemplateURIUpdated(string baseURI, string suffixURI);
  event MintedERC721(address indexed token, uint256[] tokenIds);
  event BurnedERC721(address indexed token, uint256[] tokenIds);
  event SeizeERC721(address indexed token, address account, uint256[] tokenIds);

  event MintFinished(address indexed token);
  event RulesDefined(address indexed token, IRule[] rules);
  event LockDefined(
    address indexed lock,
    address sender,
    address receiver,
    uint256 startAt,
    uint256 endAt
  );
  event Freeze(
    address indexed token,
    address address_,
    uint256 until);
  event TokenLocksDefined(
    address indexed token,
    address[] locks);
  event TokenDefined(
    address indexed token,
    string name,
    string symbol);

  event LogTransferData(
    address token, address caller, address sender, address receiver,
    uint256 senderId, uint256[] senderKeys, bool senderFetched,
    uint256 receiverId, uint256[] receiverKeys, bool receiverFetched,
    uint256 value, uint256 convertedValue);
  event LogTransferAuditData(
    uint256 auditConfigurationId, uint256 scopeId,
    address currency, IRatesProvider ratesProvider,
    bool senderAuditRequired, bool receiverAuditRequired);
  event LogAuditData(
    uint64 createdAt, uint64 lastTransactionAt,
    uint256 cumulatedEmission, uint256 cumulatedReception
  );
}
