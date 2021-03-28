pragma solidity ^0.8.0;

import "../core/Core.sol";


/**
 * @title CoreMock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
contract CoreMock is Core {

  function defineDelegateMock(uint256 _delegateId, address _delegate) public returns (bool) {
    return defineDelegateInternal(_delegateId, _delegate);
  }

  function defineProxyMock(address _proxy, uint256 _delegateId) public returns (bool) {
    return defineProxyInternal(_proxy, _delegateId);
  }

  function successOnlyProxy(bool _success) public view onlyProxy returns (bool) {
    return _success;
  }

  function delegateMockTxSuccess(bool) public returns (bool) {
    return delegateCall();
  }

  function delegateCallBoolMock(bool) public returns (bool) {
    return delegateCallBool();
  }

  function delegateCallUint256Mock(uint256) public returns (uint256) {
    return delegateCallUint256();
  }

  function delegateCallBytesMock(bytes memory) public returns (bytes memory) {
    return delegateCallBytes();
  }

  function delegateCallStringMock(string memory) public returns (string memory) {
    return delegateCallString();
  }

  function migrateProxyMock(address _proxy, address _newCore) public returns (bool) {
    return migrateProxyInternal(_proxy, _newCore);
  }

  function removeProxyMock(address _proxy) public returns (bool) {
    return removeProxyInternal(_proxy);
  }
}
