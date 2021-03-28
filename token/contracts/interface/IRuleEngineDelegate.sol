pragma solidity ^0.8.0;

import "../interface/IRule.sol";


/**
 * @title Rule Engine Delegate Interface
 * @dev Rule Engine Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
abstract contract IRuleEngineDelegate {

  function defineRules(address _token, IRule[] memory _rules) public virtual returns (bool);
}
