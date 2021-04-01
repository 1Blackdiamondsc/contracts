pragma solidity ^0.8.0;

import "../interface/ITokenStorage.sol";


/**
 * @title Base Token Delegate Interface
 * @dev Base Token Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IBaseTokenDelegate is ITokenStorage {

  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function totalSupply() external view returns (uint256);
  function balanceOf(address _owner) external view returns (uint256);

  function checkConfigurations(uint256[] calldata _auditConfigurationIds)
    external view returns (bool);

  function token(IProxy _token) external view returns (
    bool mintingFinished,
    uint256 allTimeMinted,
    uint256 allTimeBurned,
    uint256 allTimeSeized,
    address[] memory locks,
    uint256 freezedUntil,
    IRule[] memory);

  function canTransfer(address, address, uint256) external returns (TransferCode);
}
