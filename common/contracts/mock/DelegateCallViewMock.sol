pragma solidity ^0.8.0;

import "../call/DelegateCallView.sol";


/**
 * @title DelegateCallViewMock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
contract DelegateCallViewMock is DelegateCallView {

  address public delegate;

  constructor(address _delegate) {
    delegate = _delegate;
  }

  function delegateCallBoolMock(bool) public view returns (bool) {
    return _delegateCallBool(delegate);
  }

  function delegateCallUint256Mock(uint256) public view returns (uint256) {
    return _delegateCallUint256(delegate);
  }

  function delegateCallBytesMock(bytes memory) public view returns (bytes memory) {
    return _delegateCallBytes(delegate);
  }

  function delegateCallStringMock(string memory) public view returns (string memory) {
    return _delegateCallString(delegate);
  }
}
