pragma solidity ^0.8.0;

import "../interface/IBaseTokenDelegate.sol";


/**
 * @title Base Token Delegate Interface
 * @dev Base Token Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IBaseTokenERC20Delegate is IBaseTokenDelegate {

  function decimals() external view returns (uint256);
  function allowance(address _owner, address _spender)
    external view returns (uint256);
  function transfer(address _sender, address _receiver, uint256 _value) external;
  function transferFrom(
    address _caller, address _sender, address _receiver, uint256 _value) external;
  function approve(address _sender, address _spender, uint256 _value) external;
  function increaseApproval(address _sender, address _spender, uint _addedValue) external;
  function decreaseApproval(address _sender, address _spender, uint _subtractedValue) external;
}
