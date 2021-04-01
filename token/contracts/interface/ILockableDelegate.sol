pragma solidity ^0.8.0;

import "../interface/ITokenStorage.sol";


/**
 * @title Lockable Delegate Interface
 * @dev Lockable Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ILockableDelegate is ITokenStorage {

  function lock(IProxy _lock, address _sender, address _receiver)
    external view returns (uint64 startAt, uint64 endAt);

  function defineTokenLocks(IProxy _token, address[] memory _locks) external returns (bool);
  function defineLock(
    address _lock,
    address _sender,
    address _receiver,
    uint64 _startAt,
    uint64 _endAt) external returns (bool);

}
