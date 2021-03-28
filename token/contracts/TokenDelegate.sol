pragma solidity ^0.8.0;

import "./interface/ITokenDelegate.sol";
import "./delegate/CompliantTokenDelegate.sol";

/**
 * @title Token Delegate
 * @dev Token Delegate
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
contract TokenDelegate is ITokenDelegate, CompliantTokenDelegate {
}
