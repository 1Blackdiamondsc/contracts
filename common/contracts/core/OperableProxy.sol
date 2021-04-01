pragma solidity ^0.8.0;

import "../interface/ICore.sol";
import "./Proxy.sol";


/**
 * @title OperableProxy
 * @dev The OperableAs contract enable the restrictions of operations to a set of operators
 * @dev It relies on another Operable contract and reuse the same list of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 * OP01: Message sender must be authorized
 */
contract OperableProxy is Proxy {

  // solhint-disable-next-line no-empty-blocks
  constructor(ICore _core) Proxy(_core) { }

  /**
   * @dev Throws if called by any account other than the operator
   */
  modifier onlyOperator {
    require(core.hasProxyPrivilege(
      msg.sender, this, msg.sig), "OP01");
    _;
  }
}
