pragma solidity ^0.8.0;

import "../interface/ICore.sol";
import "../interface/IProxy.sol";


/**
 * @title OperableAsCore
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   OA01: Missing the core privilege
 *   OA02: Missing the proxy privilege
 **/
contract OperableAsCore {

  modifier onlyCoreOperator(ICore _core) {
    require(_core.hasCorePrivilege(
      msg.sender, msg.sig), "OA01");
    _;
  }

  modifier onlyProxyOperator(IProxy _proxy) {
    require(isProxyOperator(msg.sender, _proxy), "OA02");
    _;
  }

  function isProxyOperator(address _operator, IProxy _proxy) internal view returns (bool) {
    ICore core = ICore(_proxy.core());
    return core.hasProxyPrivilege(
      _operator, _proxy, msg.sig);
  }
}
