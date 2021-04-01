pragma solidity ^0.8.0;

import "../interface/IProxy.sol";
import "../call/DelegateCall.sol";


/**
 * @title Proxy
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   PR01: Only accessible by core
 *   PR02: Core request should be successful
 **/
contract Proxy is IProxy {
  using DelegateCall for address;

  ICore public override core;

  /**
   * @dev Throws if called by any account other than a core
   */
  modifier onlyCore {
    require(address(core) == msg.sender, "PR01");
    _;
  }

  constructor(ICore _core) {
    core = _core;
  }

  /**
   * @dev update the core
   */
  function updateCore(ICore _core)
    public override onlyCore returns (bool)
  {
    core = _core;
    return true;
  }

  /**
   * @dev static call to the core
   * @dev in order to read core value through internal core delegateCall
   */
  function staticCallUint256() internal view returns (uint256 value) {
    value = abi.decode(address(core)._forwardStaticCall(msg.data), (uint256));
  }

  /**
   * @dev static call to the core
   * @dev in order to read core value through internal core delegateCall
   */
  function staticCallString() internal view returns (string memory value) {
    value = abi.decode(address(core)._forwardStaticCall(msg.data), (string));
  }
}
