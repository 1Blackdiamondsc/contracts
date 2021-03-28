pragma solidity ^0.8.0;

import "./IBaseTokenDelegate.sol";
import "./ILockableDelegate.sol";
import "./IMintableDelegate.sol";
import "./IRuleEngineDelegate.sol";


/**
 * @title Token Delegate Interface
 * @dev Token Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
abstract contract ITokenDelegate is
  ILockableDelegate, IRuleEngineDelegate, IMintableDelegate, IBaseTokenDelegate
{

}
