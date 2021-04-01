pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/IERC20.sol";
import "@c-layer/common/contracts/interface/IProxy.sol";


/**
 * @title ITokenERC20 proxy
 * @dev Token proxy interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
interface ITokenERC20Proxy is IERC20, IProxy {

  function canTransfer(address, address, uint256) external view returns (uint256);
  function emitTransfer(address _from, address _to, uint256 _value) external returns (bool);
  function emitApproval(address _owner, address _spender, uint256 _value) external returns (bool);
}
