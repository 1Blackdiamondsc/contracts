pragma solidity ^0.8.0;

import "../interface/IProxy.sol";


/**
 * @title Storage
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 **/
contract Storage {

  struct RoleData {
    mapping(bytes4 => bool) privileges;
  }

  struct OperatorData {
    bytes32 coreRole;
    mapping(IProxy => bytes32) proxyRoles;
  }

  mapping(IProxy => uint256) internal proxyDelegateIds;
  mapping(uint256 => address) internal delegates;

  mapping (address => OperatorData) internal operators;
  mapping (bytes32 => RoleData) internal roles;
}
