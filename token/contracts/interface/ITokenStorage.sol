pragma solidity ^0.8.0;

import "@c-layer/oracle/contracts/interface/IUserRegistry.sol";
import "@c-layer/oracle/contracts/interface/IRatesProvider.sol";
import "./IRule.sol";
import "./ITokenERC20Proxy.sol";


/**
 * @title ITokenStorage
 * @dev Token storage interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
interface ITokenStorage {
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

  event OracleDefinition(
    IUserRegistry userRegistry,
    IRatesProvider ratesProvider,
    address currency);
  event TokenDelegateDefinition(uint256 indexed delegateId, address delegate, uint256[] configurations);
  event TokenDelegateRemoved(uint256 indexed delegateId);
  event AuditConfigurationDefinition(
    uint256 indexed configurationId,
    uint256 scopeId,
    AuditTriggerMode mode,
    uint256[] senderKeys,
    uint256[] receiverKeys,
    IRatesProvider ratesProvider,
    address currency);
  event AuditTriggersDefinition(
    uint256 indexed configurationId,
    address[] senders,
    address[] receivers,
    AuditTriggerMode[] modes);
  event AuditsRemoved(address scope, uint256 scopeId);
  event SelfManaged(address indexed holder, bool active);

  // ERC20
  event MintERC20(ITokenERC20Proxy indexed token, uint256 amount);
  event BurnERC20(ITokenERC20Proxy indexed token, uint256 amount);
  event SeizeERC20(ITokenERC20Proxy indexed token, address account, uint256 amount);

  // ERC721
  event ERC721TemplateURIUpdated(string baseURI, string suffixURI);
  event MintERC721(IProxy indexed token, uint256[] tokenIds);
  event BurnERC721(IProxy indexed token, uint256[] tokenIds);
  event SeizeERC721(IProxy indexed token, address account, uint256[] tokenIds);

  event MintFinish(IProxy indexed token);
  event RulesDefinition(IProxy indexed token, IRule[] rules);
  event LockDefinition(
    address indexed lock,
    address sender,
    address receiver,
    uint256 startAt,
    uint256 endAt
  );
  event Freeze(
    IProxy indexed token,
    address address_,
    uint256 until);
  event TokenLocksDefinition(
    IProxy indexed token,
    address[] locks);
  event TokenDefinition(
    IProxy indexed token,
    string name,
    string symbol);

  event LogTransferData(
    IProxy token, address caller, address sender, address receiver,
    uint256 senderId, uint256[] senderKeys, bool senderFetched,
    uint256 receiverId, uint256[] receiverKeys, bool receiverFetched,
    uint256 value, uint256 tokenId, uint256 convertedValue);
  event LogTransferAuditData(
    uint256 auditConfigurationId, uint256 scopeId,
    address currency, IRatesProvider ratesProvider,
    bool senderAuditRequired, bool receiverAuditRequired);
  event LogAuditData(
    uint64 createdAt, uint64 lastTransactionAt,
    uint256 cumulatedEmission, uint256 cumulatedReception
  );
}
