pragma solidity ^0.8.0;

import "./IRule.sol";
import "./ITokenStorage.sol";


/**
 * @title Rule Engine Delegate Interface
 * @dev Rule Engine Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IRuleEngineDelegate is ITokenStorage {

  function defineRules(IProxy _token, IRule[] memory _rules) external returns (bool);
}
