pragma solidity ^0.8.0;

import "../core/Proxy.sol";
import "./DelegateMock.sol";


/**
 * @title ProxyMock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
contract ProxyMock is Proxy {

  constructor(ICore _core) Proxy(_core) { }

  function successOnlyCore(bool _success) public view onlyCore returns (bool) {
    return _success;
  }

  function staticCallUint256Mock(uint256) public view returns (uint256) {
    return staticCallUint256();
  }

  function delegateCallUint256Mock(uint256 _value) public {
    DelegateMock(address(core)).delegateCallUint256Mock(_value);
  }

  function staticCallStringMock(string memory) public view returns (string memory) {
    return staticCallString();
  }

  function delegateCallStringMock(string memory _message) public {
    DelegateMock(address(core)).delegateCallStringMock(_message, address(core));
  }
}
