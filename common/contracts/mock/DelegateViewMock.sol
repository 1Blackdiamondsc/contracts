pragma solidity ^0.8.0;

import "../core/Delegate.sol";


/**
 * @title DelegateViewMock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   DVM01: Bool must be not null
 *   DVM02: Value must be defined
 *   DVM03: Bytes must be defined
 *   DVM04: String must be defined
 */
contract DelegateViewMock is Delegate {

  function delegateCallBoolMock(bool _success) public pure returns (bool) {
    require(_success, "DVM01");
    return _success;
  }

  function delegateCallUint256Mock(uint256 _value) public pure returns (uint256) {
    require(_value != 0, "DVM02");
    return _value;
  }

  function delegateCallBytesMock(bytes memory _data) public pure returns (bytes memory) {
    require(_data.length > 0, "DVM03");
    return _data;
  }

  function delegateCallStringMock(string memory _message) public pure returns (string memory) {
    require(bytes(_message).length > 0, "DVM04");
    return _message;
  }
}
