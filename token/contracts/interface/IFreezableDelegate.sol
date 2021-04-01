pragma solidity ^0.8.0;

import "./ITokenStorage.sol";


/**
 * @title Freezable Delegate Interface
 * @dev Freezable Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IFreezableDelegate is ITokenStorage {


  function freezeManyAddresses(
    IProxy _token,
    address[] memory _addresses,
    uint256 _until) external returns (bool);
}
