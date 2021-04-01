pragma solidity ^0.8.0;

import "./IBaseTokenERC20Delegate.sol";
import "./IMintableERC20Delegate.sol";
import "./ISeizableERC20Delegate.sol";
import "./ITokenDelegate.sol";


/**
 * @title Token ERC20 Delegate Interface
 * @dev Token ERC20 Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ITokenERC20Delegate is
  ITokenDelegate, ISeizableERC20Delegate, IMintableERC20Delegate, IBaseTokenERC20Delegate
{
}
