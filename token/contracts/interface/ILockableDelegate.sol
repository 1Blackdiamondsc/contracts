pragma solidity ^0.8.0;


/**
 * @title Lockable Delegate Interface
 * @dev Lockable Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
abstract contract ILockableDelegate {

  function defineTokenLocks(address _token, address[] memory _locks) public virtual returns (bool);
  function defineLock(
    address _lock,
    address _sender,
    address _receiver,
    uint64 _startAt,
    uint64 _endAt) public virtual returns (bool);

}
