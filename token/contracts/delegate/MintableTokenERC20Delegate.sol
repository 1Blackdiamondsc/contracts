pragma solidity ^0.8.0;

import "./MintableERC20Delegate.sol";
import "./BaseTokenERC20Delegate.sol";
import "./RuleEngineDelegate.sol";


/**
 * @title Token Delegate
 * @dev Token Delegate
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
contract MintableTokenERC20Delegate is RuleEngineDelegate, MintableERC20Delegate, BaseTokenERC20Delegate {
}
