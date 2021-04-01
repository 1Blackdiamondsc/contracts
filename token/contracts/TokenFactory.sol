pragma solidity ^0.8.0;

import "@c-layer/common/contracts/factory/Factory.sol";
import "@c-layer/common/contracts/operable/Operable.sol";
import "@c-layer/common/contracts/operable/OperableAsCore.sol";
import "@c-layer/common/contracts/interface/IERC20.sol";
import "@c-layer/distribution/contracts/interface/IWrappedERC20.sol";
import "./interface/ITokenCore.sol";
import "./interface/ITokenERC20Delegate.sol";
import "./interface/ITokenERC20Proxy.sol";
import "./interface/ITokenFactory.sol";
import "./rule/YesNoRule.sol";
import "./TokenAccessDefinitions.sol";


/**
 * @title TokenFactory
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   TF01: required privileges must be granted from the core to the factory
 *   TF02: There must be the same number of vault and supplies
 *   TF03: Token proxy contract must be deployed
 *   TF04: Token must be defined in the core
 *   TF05: Issuer role must be granted on the proxy
 *   TF06: The rule must be set
 *   TF07: The token must have its locks
 *   TF08: The token must be locked
 *   TF09: Token must be minted
 *   TF10: Token minting must be finished
 *   TF11: Incorrect core provided
 *   TF12: The rule must be removed
 *   TF13: DefineAuditTriggers privileges is required for setting compliance
 *   TF14: Wrapped token contract must be deployed
 *   TF15: Wrapped token contract should be operator on token
 *   TF16: Audit triggers should be successfully configured
 *   TF17: Wrapped tokens should be distributed
 *   TF18: WWrapped token contract should be approved on token
 *   TF19: Wrapped token contract should be operator on token
 *   TF20: Same number of tokensales and allowances must be provided
 *   TF21: Exceptions must be added to the lock
 *   TF22: Allowance must be lower than the token balance
 *   TF23: Allowance must be successful
 **/
contract TokenFactory is
  ITokenFactory, Factory, OperableAsCore, YesNoRule, Operable, TokenAccessDefinitions
{

  // The definitions below should be considered as a constant
  // Solidity 0.6.x do not provide ways to have arrays as constants
  bytes4[] public requiredCorePrivileges = [
    ASSIGN_PROXY_OPERATORS_PRIV,
    DEFINE_TOKEN_PRIV,
    DEFINE_AUDIT_TRIGGERS_PRIV
  ];
  bytes4[] public requiredProxyPrivileges = [
    MINT_PRIV,
    FINISH_MINTING_PRIV,
    DEFINE_LOCK_PRIV,
    DEFINE_TOKEN_LOCK_PRIV,
    DEFINE_RULES_PRIV
  ];

  /*
   * @dev constructor
   */
  constructor() YesNoRule(false) {}

  /*
   * @dev has core access
   */
  function hasCoreAccess(ITokenCore _core) override public view returns (bool access) {
    access = true;
    for (uint256 i=0; i<requiredCorePrivileges.length; i++) {
      access = access && _core.hasCorePrivilege(
        address(this), requiredCorePrivileges[i]);
    }

    for (uint256 i=0; i<requiredProxyPrivileges.length; i++) {
      access = access && _core.hasProxyPrivilege(
        address(this), ALL_PROXIES, requiredProxyPrivileges[i]);
    }
  }

  /**
   * @dev defineBlueprint
   */
  function defineBlueprint(
    uint256 _id,
    address _template,
    bytes memory _bytecode,
    bytes memory _defaultParameters) override public onlyOperator returns (bool)
  {
    return defineBlueprintInternal(_id, _template, _bytecode, _defaultParameters);
  }

  /**
   * @dev deployContract
   */
  function deployContract(uint256 _id, bytes memory _parameters)
    public override returns (address)
  {
    return deployContractInternal(_id, _parameters);
  }

  /**
   * @dev deploy token
   */
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
  ) override public returns (IERC20) {
    require(hasCoreAccess(_core), "TF01");
    require(_vaults.length == _supplies.length, "TF02");

    // 1- Creating a proxy
    ITokenERC20Proxy token = ITokenERC20Proxy(deployContractInternal(
      uint256(ProxyCode.TOKEN), abi.encode(address(_core))));
    require(address(token) != address(0), "TF03");

    // 2- Defining the token in the core
    _core.defineToken(token, _delegateId, _name, _symbol, _decimals);

    // 3- Assign roles
    _core.assignProxyOperators(token, ISSUER_PROXY_ROLE, _proxyOperators);

    // 4- Define rules
    // Token is blocked for review and approval by core operators
    // This contract is used as a YesNo rule configured as No to prevent transfers
    // Removing this contract from the rules will unlock the token
    ITokenERC20Delegate coreAsDelegate = ITokenERC20Delegate(address(_core));
    if (!_core.hasCorePrivilege(msg.sender, APPROVE_TOKEN_PRIV)) {
      IRule[] memory factoryRules = new IRule[](1);
      factoryRules[0] = IRule(address(this));
      coreAsDelegate.defineRules(token, factoryRules);
    }

    // 5- Locking the token
    address[] memory locks = new address[](1);
    locks[0] = address(token);
    coreAsDelegate.defineTokenLocks(token, locks);

    // solhint-disable-next-line not-rely-on-time
    if (_lockEnd > block.timestamp) {
      coreAsDelegate.defineLock(
        address(token),
        ANY_ADDRESSES,
        ANY_ADDRESSES,
        0,
        _lockEnd);
    }

    // 6- Mint the token
    coreAsDelegate.mint(token, _vaults, _supplies);

    // 7 - Finish the minting
    if(_finishMinting) {
      coreAsDelegate.finishMinting(token);
    }

    emit ProxyDeployed(token);
    return token;
  }

  /**
   * @dev approveToken
   */
  function approveToken(ITokenCore _core, IProxy _token)
    override public onlyCoreOperator(_core) returns (bool)
  {
    require(hasCoreAccess(_core), "TF01");
    require(_token.core() == _core, "TF11");

    // This ensure that the call does not change a custom made rules configuration
    ITokenERC20Delegate coreAsDelegate = ITokenERC20Delegate(address(_core));
    (,,,,,,IRule[] memory rules) = coreAsDelegate.token(_token);
    if (rules.length == 1 && rules[0] == IRule(this)) {
      coreAsDelegate.defineRules(_token, new IRule[](0));
    }
    emit ProxyApproved(_token);
    return true;
  }

  /**
   * @dev deploy wrapped token
   */
  function deployWrappedToken(
    ITokenERC20Proxy _token,
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    address[] memory _vaults,
    uint256[] memory _supplies,
    bool _compliance
  ) override public onlyProxyOperator(_token) returns (IERC20) {
    require(_vaults.length == _supplies.length, "TF02");

    ITokenCore core;
    if (_compliance) {
      core = ITokenCore(payable(_token.core()));
      require(hasCoreAccess(core), "TF01");
      require(core.hasCorePrivilege(msg.sender, DEFINE_AUDIT_TRIGGERS_PRIV), "TF13");
    }

    // 1- Creating a wrapped token
    IWrappedERC20 wToken = IWrappedERC20(deployContractInternal(
      uint256(ProxyCode.WRAPPED_TOKEN),
      abi.encode(_name, _symbol, _decimals, address(_token))));
    require(address(wToken) != address(0), "TF14");

    emit WrappedTokenDeployed(_token, wToken);

    // 2- Compliance Configuration
    if (_compliance) {
      // Avoid the approval step for non self managed users
      address[] memory operators = new address[](1);
      operators[0] = address(wToken);
      core.assignProxyOperators(_token, OPERATOR_PROXY_ROLE, operators);

      ITokenDelegate coreAsDelegate = ITokenDelegate(address(core));

      // Avoid KYC restrictions for the wrapped tokens (AuditConfigurationId == 0)
      {
        uint256 delegateId = core.proxyDelegateId(_token);
        uint256 auditConfigurationId = core.delegatesConfigurations(delegateId)[0];
        address[] memory senders = new address[](2);
        senders[0] = ANY_ADDRESSES;
        senders[1] = address(wToken);
        address[] memory receivers = new address[](2);
        receivers[0] = address(wToken);
        receivers[1] = ANY_ADDRESSES;
        ITokenStorage.AuditTriggerMode[] memory modes = new ITokenStorage.AuditTriggerMode[](2);
        modes[0] = ITokenStorage.AuditTriggerMode.NONE;
        modes[1] = ITokenStorage.AuditTriggerMode.RECEIVER_ONLY;
        core.defineAuditTriggers(auditConfigurationId,
          senders, receivers, modes);
      }

      coreAsDelegate.defineLock(address(_token), address(this), ANY_ADDRESSES, ~uint64(0), ~uint64(0));
    } else {
      _token.approve(address(wToken), ~uint256(0));
    }

    // 3- Wrap tokens
    for(uint256 i=0; i < _vaults.length; i++) {
      wToken.depositTo(_vaults[i], _supplies[i]);
    }

    return wToken;
  }

  /**
   * @dev configureTokensales
   */
  function configureTokensales(
    ITokenERC20Proxy _token,
    address[] memory _tokensales,
    uint256[] memory _allowances)
    override public onlyProxyOperator(_token) returns (bool)
  {
    ITokenCore core = ITokenCore(payable(_token.core()));
    require(hasCoreAccess(core), "TF01");
    require(_tokensales.length == _allowances.length, "TF20");

    ITokenDelegate coreAsDelegate = ITokenDelegate(address(core));
    for(uint256 i=0; i < _tokensales.length; i++) {
      coreAsDelegate.defineLock(address(_token), _tokensales[i], ANY_ADDRESSES, ~uint64(0), ~uint64(0));
    }

    updateAllowances(_token, _tokensales, _allowances);
    emit TokensalesConfigured(_token, _tokensales);
    return true;
  }

  /**
   * @dev updateAllowance
   */
  function updateAllowances(
    ITokenERC20Proxy _token,
    address[] memory _spenders,
    uint256[] memory _allowances)
    override public onlyProxyOperator(_token) returns (bool)
  {
    uint256 balance = _token.balanceOf(address(this));
    for(uint256 i=0; i < _spenders.length; i++) {
      require(_allowances[i] <= balance, "TF22");
      _token.approve(_spenders[i], _allowances[i]);
      emit AllowanceUpdated(_token, _spenders[i], _allowances[i]);
    }
    return true;
  }
}
