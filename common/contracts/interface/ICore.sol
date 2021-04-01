pragma solidity ^0.8.0;

import "./IProxy.sol";


/**
 * @title ICore
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface ICore {

  event RoleDefinition(bytes32 role);
  event OperatorAssigned(bytes32 role, address operator);
  event ProxyOperatorAssigned(IProxy proxy, bytes32 role, address operator);
  event OperatorRevoked(address operator);
  event ProxyOperatorRevoked(IProxy proxy, address operator);

  event ProxyDefinition(IProxy proxy, uint256 delegateId);
  event ProxyMigration(IProxy proxy, ICore newCore);
  event ProxyRemoved(IProxy proxy);

  function proxyDelegateId(IProxy _proxy) external view returns (uint256);
  function delegate(uint256 _delegateId) external view returns (address);

  function coreRole(address _address) external view returns (bytes32);
  function proxyRole(IProxy _proxy, address _address) external view returns (bytes32);
  function rolePrivilege(bytes32 _role, bytes4 _privilege) external view returns (bool);
  function roleHasPrivilege(bytes32 _role, bytes4 _privilege) external view returns (bool);
  function hasCorePrivilege(address _address, bytes4 _privilege) external view returns (bool);
  function hasProxyPrivilege(address _address, IProxy _proxy, bytes4 _privilege)
    external view returns (bool);

  receive() external payable;
  fallback() external payable;

  function delegateCall(bytes calldata _data) external returns (bytes memory);
  function delegateCallView(bytes calldata _data) external view returns (bytes memory);

  function defineRole(bytes32 _role, bytes4[] memory _privileges) external;
  function assignOperators(bytes32 _role, address[] memory _operators) external;
  function assignProxyOperators(
    IProxy _proxy, bytes32 _role, address[] memory _operators) external;
  function revokeOperators(address[] memory _operators) external;
  function revokeProxyOperators(IProxy _proxy, address[] memory _operators) external;

  function defineProxy(IProxy _proxy, uint256 _delegateId) external;
  function migrateProxy(IProxy _proxy, ICore _newCore) external;
  function removeProxy(IProxy _proxy) external;
}
