pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/IERC20.sol";
import "../interface/ITokenCore.sol";
import "../interface/ITokenERC20Proxy.sol";


/**
 * @title ITokenFactory
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 **/
interface ITokenFactory {

  enum ProxyCode {
    TOKEN,
    WRAPPED_TOKEN
  }

  function hasCoreAccess(ITokenCore _core) external view returns (bool access);

  function deployToken(
    ITokenCore _core,
    uint256 _delegateId,
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    uint64 _lockEnd,
    bool _finishMinting,
    address[] memory _vaults,
    uint256[] memory _supplies,
    address[] memory _proxyOperators
  ) external returns (IERC20);
  function approveToken(ITokenCore _core, IProxy _token) external returns (bool);

  function deployWrappedToken(
    ITokenERC20Proxy _token,
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    address[] memory _vaults,
    uint256[] memory _supplies,
    bool _compliance
  ) external returns (IERC20);

  function configureTokensales(
    ITokenERC20Proxy _token,
    address[] memory _tokensales,
    uint256[] memory _allowances) external returns (bool);
  function updateAllowances(
    ITokenERC20Proxy _token,
    address[] memory _spenders,
    uint256[] memory _allowances) external returns (bool);

  event ProxyDeployed(IProxy token);
  event ProxyApproved(IProxy token);
  event WrappedTokenDeployed(IERC20 token, IERC20 wrapped);
  event TokensalesConfigured(IERC20 token, address[] tokensales);
  event AllowanceUpdated(IERC20 token, address spender, uint256 allowance);
}
