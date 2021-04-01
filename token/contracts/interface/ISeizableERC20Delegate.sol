pragma solidity ^0.8.0;

import "./IBaseTokenERC20Delegate.sol";
import "./IMintableERC20Delegate.sol";
import "./ITokenERC20Proxy.sol";
import "./ITokenDelegate.sol";


/**
 * @title Seizable Delegate Interface
 * @dev Seizable Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ISeizableERC20Delegate {

  function seize(ITokenERC20Proxy _token, address _account, uint256 _amount)
    external returns (bool);
}
