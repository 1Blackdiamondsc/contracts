pragma solidity ^0.6.0;

import "./DelegateMock.sol";
import "../delegate/OracleEnrichedDelegate.sol";


/**
 * @title OracleEnrichedDelegateMock
 * @dev OracleEnrichedDelegateMock contract
 * @dev Enriched the transfer with oracle's informations
 * @dev needed for the delegate processing
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
contract OracleEnrichedDelegateMock is OracleEnrichedDelegate, DelegateMock {

  uint256 constant AUDIT_CONFIGURATION_DEFAULT = 0;

  /**
   * @dev testFetchSenderUser
   */
  function testFetchSenderUser(address _sender, uint256[] memory _userKeys)
    public returns (bool)
  {
    STransferData memory transferData_ = transferData(
      address(0), address(0), _sender, address(0), 0);
    AuditConfiguration storage configuration =
      auditConfigurations[AUDIT_CONFIGURATION_DEFAULT];
    configuration.senderKeys = _userKeys;

    super.fetchSenderUser(transferData_, configuration.senderKeys);
    logTransferData(transferData_);
    return true;
  }

  /**
   * @dev testFetchReceiverUser
   */
  function testFetchReceiverUser(address _receiver, uint256[] memory _userKeys)
    public returns (bool)
  {
    STransferData memory transferData_ = transferData(
      address(0), address(0), address(0), _receiver, 0);
    AuditConfiguration storage configuration =
      auditConfigurations[AUDIT_CONFIGURATION_DEFAULT];
    configuration.receiverKeys = _userKeys;

    super.fetchReceiverUser(transferData_, configuration.receiverKeys);
    logTransferData(transferData_);
    return true;
  }

  /**
   * @dev testFetchConvertedValue
   */
  function testFetchConvertedValue(
    uint256 _value, IRatesProvider _ratesProvider,
    address _token, address _currencyTo)
    public returns (bool)
  {
    STransferData memory transferData_ = transferData(
      _token, address(0), address(0), address(0), _value);
    AuditConfiguration storage configuration =
      auditConfigurations[AUDIT_CONFIGURATION_DEFAULT];
    configuration.ratesProvider = _ratesProvider;
    configuration.currency = _currencyTo;

    super.fetchConvertedValue(transferData_, configuration);
    logTransferData(transferData_);
    return true;
  }
}
