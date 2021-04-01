pragma solidity ^0.8.0;

import "./ILockableDelegate.sol";
import "./IRuleEngineDelegate.sol";
import "./IFreezableDelegate.sol";


/**
 * @title Token Delegate Interface
 * @dev Token Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ITokenDelegate is IFreezableDelegate, ILockableDelegate, IRuleEngineDelegate {
}
