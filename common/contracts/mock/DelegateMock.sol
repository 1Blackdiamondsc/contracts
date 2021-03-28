pragma solidity ^0.8.0;

import "../core/Delegate.sol";


/**
 * @title DelegateMock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   DM01: Must be a successful transaction
 *   DM02: Must be a unsucessful transaction
 *   DM03: Call must return true
 *   DM04: Call must return false
 *   DM05: Value must be 0
 *   DM06: Data must not be null
 *   DN07: Message must not be null
 */
contract DelegateMock is Delegate {

  bool public success;
  uint256 public value;
  bytes public data;
  string public message;

  function delegateMockTxSuccess(bool _success) public returns (bool) {
    require(_success, "DM01");
    success = _success;
    return _success;
  }

  function delegateMockTxFail(bool _success) public returns (bool) {
    require(!_success, "DM02");
    success = _success;
    return _success;
  }

  function delegateCallBoolMock(bool _success) public returns (bool) {
    require(_success, "DM03");
    success = _success;
    return _success;
  }

  function delegateCallBoolFalseMock(bool _success) public returns (bool) {
    require(!_success, "DM04");
    success = _success;
    return _success;
  }

  function delegateCallUint256Mock(uint256 _value) public returns (uint256) {
    require(_value != 0, "DM05");
    value = _value;
    return _value;
  }

  function delegateCallBytesMock(bytes memory _data) public returns (bytes memory) {
    require(_data.length > 0, "DM06");
    data = _data;
    return _data;
  }

  function delegateCallStringMock(string memory _message) public returns (bytes memory) {
    require(bytes(_message).length > 0, "DM07");
    message = _message;
    return abi.encode(_message);
  }
}
