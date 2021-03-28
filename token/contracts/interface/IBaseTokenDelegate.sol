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
abstract contract IBaseTokenDelegate is ITokenStorage {

  function decimals() virtual public view returns (uint256);
  function totalSupply() virtual public view returns (uint256);
  function balanceOf(address _owner) virtual public view returns (uint256);
  function allowance(address _owner, address _spender)
    virtual public view returns (uint256);
  function transfer(address _sender, address _receiver, uint256 _value)
    virtual public returns (bool);
  function transferFrom(
    address _caller, address _sender, address _receiver, uint256 _value)
    virtual public returns (bool);
  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _value) virtual public view returns (TransferCode);
  function approve(address _sender, address _spender, uint256 _value)
    virtual public returns (bool);
  function increaseApproval(address _sender, address _spender, uint _addedValue)
    virtual public returns (bool);
  function decreaseApproval(address _sender, address _spender, uint _subtractedValue)
    virtual public returns (bool);

  function checkConfigurations(uint256[] calldata _auditConfigurationIds)
    virtual public view returns (bool);
}
