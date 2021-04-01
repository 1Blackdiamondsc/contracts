pragma solidity ^0.8.0;

import "../interface/ICore.sol";
import "./OperableStorage.sol";
import "../call/DelegateCall.sol";
import "../convert/BytesConvert.sol";


/**
 * @title Core
 * @dev The Operable contract enable the restrictions of operations to a set of operators
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   CO01: Sender is not a system operator
 *   CO02: Sender is not a core operator
 *   CO03: Sender is not a proxy operator
 *   CO04: Delegate must exist
 *   CO05: Role must not be null
 *   CO06: AllPrivileges is a reserved role
 *   CO07: Proxy must be valid
 *   CO08: Operator has no role
 *   CO09: AllProxies is not a valid proxy address
 *   CO10: Delegate must exist
 *   CO11: Proxy must not be null
 *   CO12: Proxy must be already defined
 *   CO13: Proxy update must be successful
  */
contract Core is ICore, OperableStorage {
  using DelegateCall for address;
  using BytesConvert for bytes;

  constructor(address[] memory _sysOperators) {
    assignOperators(ALL_PRIVILEGES, _sysOperators);
    assignProxyOperators(ALL_PROXIES, ALL_PRIVILEGES, _sysOperators);
  }

  /**
   * @dev onlyProxy modifier
   */
  modifier onlyProxy {
    require(delegates[proxyDelegateIds[IProxy(msg.sender)]] != address(0), "CO01");
    _;
  }

  /**
   * @dev onlySysOp modifier
   * @dev for safety reason, core owner
   * @dev can always define roles and assign or revoke operatos
   */
  modifier onlySysOp() {
    require(msg.sender == owner || hasCorePrivilege(msg.sender, msg.sig), "CO01");
    _;
  }

  /**
   * @dev onlyCoreOp modifier
   */
  modifier onlyCoreOp() {
    require(hasCorePrivilege(msg.sender, msg.sig), "CO02");
    _;
  }

  /**
   * @dev onlyProxyOp modifier
   */
  modifier onlyProxyOp(IProxy _proxy) {
    require(hasProxyPrivilegeInternal(msg.sender, _proxy, msg.sig), "CO03");
    _;
  }

  /**
   * @dev proxyDelegateId
   */
  function proxyDelegateId(IProxy _proxy) override public view returns (uint256) {
    return proxyDelegateIds[_proxy];
  }

  /**
   * @dev delegate
   */
  function delegate(uint256 _delegateId) override public view returns (address) {
    return delegates[_delegateId];
  }

  /**
   * @dev core role
   * @param _address operator address
   */
  function coreRole(address _address) override public view returns (bytes32) {
    return operators[_address].coreRole;
  }

  /**
   * @dev proxy role
   * @param _address operator address
   */
  function proxyRole(IProxy _proxy, address _address)
    override public view returns (bytes32)
  {
    return operators[_address].proxyRoles[_proxy];
  }

  /**
   * @dev has role privilege
   * @dev low level access to role privilege
   * @dev ignores ALL_PRIVILEGES role
   */
  function rolePrivilege(bytes32 _role, bytes4 _privilege)
    override public view returns (bool)
  {
    return roles[_role].privileges[_privilege];
  }

  /**
   * @dev roleHasPrivilege
   */
  function roleHasPrivilege(bytes32 _role, bytes4 _privilege) override public view returns (bool) {
    return (_role == ALL_PRIVILEGES) || roles[_role].privileges[_privilege];
  }

  /**
   * @dev hasCorePrivilege
   * @param _address operator address
   */
  function hasCorePrivilege(address _address, bytes4 _privilege) override public view returns (bool) {
    bytes32 role = operators[_address].coreRole;
    return (role == ALL_PRIVILEGES) || roles[role].privileges[_privilege];
  }

  /**
   * @dev hasProxyPrivilege
   * @dev the default proxy role can be set with proxy address(0)
   * @param _address operator address
   */
  function hasProxyPrivilege(address _address, IProxy _proxy, bytes4 _privilege)
    override public view returns (bool)
  {
    return hasProxyPrivilegeInternal(_address, _proxy, _privilege);
  }

  receive() external override payable {
    fallbackInternal();
  }

  fallback() external override payable {
    fallbackInternal();
  }

  function fallbackInternal() internal {
    delegateCall(msg.data);
  }

  function extractDelegateInternal(bytes calldata _data)
    internal view returns (address delegate_)
  {
    delegate_ = delegates[proxyDelegateIds[IProxy(msg.sender)]];
    if (delegate_ == address(0)) {
      IProxy proxy = IProxy(address(uint160(uint256((_data).firstParameter()))));
      delegate_ = delegates[proxyDelegateIds[proxy]];
      require(delegate_ != address(0), "CO04");
      require(msg.sender == address(this) ||
        hasProxyPrivilegeInternal(msg.sender, proxy, msg.sig), "CO03");
    } else {
      require(delegate_ != address(0), "CO04");
    }
  }

  function delegateCall(bytes calldata _data) public override returns (bytes memory){
    return extractDelegateInternal(_data)._delegateCall(_data);
  }

  function delegateCallView(bytes calldata _data) public override view returns (bytes memory) {
    return address(this)._forwardStaticCall(_data);
  }

  /**
   * @dev defineRoles
   * @param _role operator role
   * @param _privileges as 4 bytes of the method
   */
  function defineRole(bytes32 _role, bytes4[] memory _privileges)
    override public onlySysOp
  {
    require(_role != bytes32(0), "CO05");
    require(_role != ALL_PRIVILEGES, "CO06");

    delete roles[_role];
    for (uint256 i=0; i < _privileges.length; i++) {
      roles[_role].privileges[_privileges[i]] = true;
    }
    emit RoleDefinition(_role);
  }

  /**
   * @dev assignOperators
   * @param _role operator role. May be a role not defined yet.
   * @param _operators addresses
   */
  function assignOperators(bytes32 _role, address[] memory _operators)
    override public onlySysOp
  {
    require(_role != bytes32(0), "CO05");

    for (uint256 i=0; i < _operators.length; i++) {
      operators[_operators[i]].coreRole = _role;
      emit OperatorAssigned(_role, _operators[i]);
    }
  }

  /**
   * @dev assignProxyOperators
   * @param _role operator role. May be a role not defined yet.
   * @param _operators addresses
   */
  function assignProxyOperators(
    IProxy _proxy, bytes32 _role, address[] memory _operators)
    override public onlySysOp
  {
    require(_proxy == ALL_PROXIES ||
      delegates[proxyDelegateIds[_proxy]] != address(0), "CO07");
    require(_role != bytes32(0), "CO05");

    for (uint256 i=0; i < _operators.length; i++) {
      operators[_operators[i]].proxyRoles[_proxy] = _role;
      emit ProxyOperatorAssigned(_proxy, _role, _operators[i]);
    }
  }

  /**
   * @dev revokeOperator
   * @param _operators addresses
   */
  function revokeOperators(address[] memory _operators)
    override public onlySysOp
  {
    for (uint256 i=0; i < _operators.length; i++) {
      OperatorData storage operator = operators[_operators[i]];
      require(operator.coreRole != bytes32(0), "CO08");
      operator.coreRole = bytes32(0);

      emit OperatorRevoked(_operators[i]);
    }
  }

  /**
   * @dev revokeProxyOperator
   * @param _operators addresses
   */
  function revokeProxyOperators(IProxy _proxy, address[] memory _operators)
    override public onlySysOp
  {
    for (uint256 i=0; i < _operators.length; i++) {
      OperatorData storage operator = operators[_operators[i]];
      require(operator.proxyRoles[_proxy] != bytes32(0), "CO08");
      operator.proxyRoles[_proxy] = bytes32(0);

      emit ProxyOperatorRevoked(_proxy, _operators[i]);
    }
  }

  /**
   * @dev defineDelegate
   */
  function defineDelegate(uint256 _delegateId, address _delegate)
    public onlyCoreOp
  {
    require(_delegateId != 0, "CO03");
    delegates[_delegateId] = _delegate;
  }

  /**
   * @dev defineProxy
   */
  function defineProxy(IProxy _proxy, uint256 _delegateId)
    override public onlyCoreOp
  {
    require(_proxy != ALL_PROXIES, "CO09");
    require(delegates[_delegateId] != address(0), "CO10");
    require(address(_proxy) != address(0), "CO11");

    proxyDelegateIds[_proxy] = _delegateId;
    emit ProxyDefinition(_proxy, _delegateId);
  }

  /**
   * @dev migrateProxy
   */
  function migrateProxy(IProxy _proxy, ICore _newCore)
    override public onlyCoreOp
  {
    require(proxyDelegateIds[_proxy] != 0, "CO12");
    require(IProxy(_proxy).updateCore(_newCore), "CO13");
    emit ProxyMigration(_proxy, _newCore);
  }

  /**
   * @dev removeProxy
   */
  function removeProxy(IProxy _proxy)
    override public onlyCoreOp
  {
    removeProxyInternal(_proxy);
  }

  function removeProxyInternal(IProxy _proxy) virtual internal {
    require(proxyDelegateIds[_proxy] != 0, "CO12");
    delete proxyDelegateIds[_proxy];
    emit ProxyRemoved(_proxy);
  }
}
