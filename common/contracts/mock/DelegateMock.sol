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

  function delegateCallBoolMock(address, bool _success) public returns (bool) {
    require(_success, "DM03");
    success = _success;
    return _success;
  }

  function delegateCallBoolMock(bool _success) public returns (bool) {
    require(_success, "DM03");
    success = _success;
    return _success;
  }

  function delegateCallUint256Mock(uint256 _value) public {
    require(_value != 0, "DM04");
    value = _value;
  }

  function delegateCallBytesMock(bytes memory _data) public returns (bytes memory) {
    require(_data.length > 0, "DM05");
    data = _data;
    return _data;
  }

  function delegateCallStringMock(string memory _message, address _address) public {
    require(bytes(_message).length > 0 && address(this) == _address, "DM06");
    message = _message;
  }

  function delegateCallViewBoolMock(address, bool _success) public view returns (bool) {
    require(_success, "DM07");
    this;
    return _success;
  }

  function delegateCallViewUint256Mock(address, uint256 _value) public view returns (uint256) {
    require(_value != 0, "DM08");
    this;
    return _value;
  }

  function delegateCallViewBytesMock(address, bytes memory _data) public view returns (bytes memory) {
    require(_data.length > 0, "DM09");
    this;
    return _data;
  }

  function delegateCallViewStringMock(address, string memory _message) public view returns (string memory) {
    require(bytes(_message).length > 0, "DM10");
    this;
    return _message;
  }

  function staticCallBoolMock(bool _success) public pure returns (bool) {
    require(_success, "DM11");
    return _success;
  }

  function staticCallUint256Mock(uint256 _value) public pure returns (uint256) {
    require(_value != 0, "DM12");
    return _value;
  }

  function staticCallBytesMock(bytes memory _data) public pure returns (bytes memory) {
    require(_data.length > 0, "DM13");
    return _data;
  }

  function staticCallStringMock(string memory _message) public pure returns (string memory) {
    require(bytes(_message).length > 0, "DM14");
    return _message;
  }
}
