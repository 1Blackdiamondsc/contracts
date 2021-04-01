pragma solidity ^0.8.0;

import "@c-layer/common/contracts/core/OperableProxy.sol";
import "./interface/ITokenERC20Proxy.sol";
import "./interface/ITokenCore.sol";
import "./interface/ITokenERC20Delegate.sol";


/**
 * @title Token proxy
 * @dev Token proxy default implementation
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
contract TokenERC20Proxy is ITokenERC20Proxy, OperableProxy {

  // solhint-disable-next-line no-empty-blocks
  constructor(ITokenCore _core) OperableProxy(_core) { }

  function name() external override view returns (string memory) {
    return staticCallString();
  }

  function symbol() external override view returns (string memory) {
    return staticCallString();
  }

  function decimals() external override view returns (uint256) {
    return staticCallUint256();
  }

  function totalSupply() external override view returns (uint256) {
    return staticCallUint256();
  }

  function balanceOf(address) external override view returns (uint256) {
    return staticCallUint256();
  }

  function allowance(address, address) external override view returns (uint256)
  {
    return staticCallUint256();
  }

  function transfer(address _to, uint256 _value) external override returns (bool)
  {
    ITokenERC20Delegate(address(core)).transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) external override returns (bool)
  {
    ITokenERC20Delegate(address(core)).transferFrom(msg.sender, _from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) external override returns (bool)
  {
    ITokenERC20Delegate(address(core)).approve(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint256 _addedValue) external override returns (bool)
  {
    ITokenERC20Delegate(address(core)).increaseApproval(msg.sender, _spender, _addedValue);
    return true;
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) external override returns (bool)
  {
    ITokenERC20Delegate(address(core)).decreaseApproval(msg.sender, _spender, _subtractedValue);
    return true;
  }

  function canTransfer(address, address, uint256) external override view returns (uint256)
  {
    return staticCallUint256();
  }

  function emitTransfer(address _from, address _to, uint256 _value)
    external override onlyCore returns (bool)
  {
    emit Transfer(_from, _to, _value);
    return true;
  }

  function emitApproval(address _owner, address _spender, uint256 _value)
    external override onlyCore returns (bool)
  {
    emit Approval(_owner, _spender, _value);
    return true;
  }
}
