pragma solidity ^0.8.0;

import "./Storage.sol";
import "./AccessDefinitions.sol";
import "../operable/Ownable.sol";


/**
 * @title OperableStorage
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 **/
contract OperableStorage is Ownable, Storage, AccessDefinitions {

  /**
   * @dev hasProxyPrivilegeInternal
   * @dev the default proxy role can be set with proxy address(0)
   * @param _address operator address
   */
  function hasProxyPrivilegeInternal(address _address, IProxy _proxy, bytes4 _privilege)
    internal view returns (bool)
  {
    OperatorData storage data = operators[_address];
    bytes32 role = (data.proxyRoles[_proxy] != bytes32(0)) ?
      data.proxyRoles[_proxy] : data.proxyRoles[ALL_PROXIES];
    return (role == ALL_PRIVILEGES) || roles[role].privileges[_privilege];
  }
}
