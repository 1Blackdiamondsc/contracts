pragma solidity ^0.8.0;

import "./ICore.sol";


/**
 * @title IProxy
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 **/
interface IProxy {

  function core() external view returns (ICore);
  function updateCore(ICore _core) external returns (bool);

}
