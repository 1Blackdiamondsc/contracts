pragma solidity ^0.8.0;

import "../interface/IProxy.sol";


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

  address public override core;

  /**
   * @dev Throws if called by any account other than a core
   */
  modifier onlyCore {
    require(core == msg.sender, "PR01");
    _;
  }

  constructor(address _core) {
    core = _core;
  }

  /**
   * @dev update the core
   */
  function updateCore(address _core)
    public onlyCore returns (bool)
  {
    core = _core;
    return true;
  }

  /**
   * @dev enforce static immutability (view)
   * @dev in order to read core value through internal core delegateCall
   */
  function staticCallUint256() internal view returns (uint256 value) {
    (bool status, bytes memory result) = core.staticcall(msg.data);
    require(status, string(result));
    value = abi.decode(result, (uint256));
  }

  /**
   * @dev enforce static immutability (view)
   * @dev in order to read core value through internal core delegateCall
   */
  function staticCallString() internal view returns (string memory value) {
    (bool status, bytes memory result) = core.staticcall(msg.data);
    require(status, string(result));
    value = abi.decode(result, (string));
  }
}
