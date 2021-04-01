pragma solidity ^0.8.0;

import "@c-layer/common/contracts/operable/OperableAsCore.sol";
import "./interface/ICoreConfiguration.sol";
import "./TokenAccessDefinitions.sol";


/**
 * @title CoreConfiguration
 * @dev CoreConfiguration
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   CC01: Some required privileges from the core are missing
 *   CC02: Revoking access from the core configuration was successful
 */
contract CoreConfiguration is ICoreConfiguration, OperableAsCore, TokenAccessDefinitions {

  uint256[] private noAMLConfig = new uint256[](0);
  uint256[] private primaryMarketAMLConfig = [ uint256(Configuration.AML_PRIMARY) ];
  uint256[] private secondaryMarketAMLConfig = [ uint256(Configuration.AML_FULL) ];

  uint256[] private emptyArray = new uint256[](0);
  uint256[] private senderKeys = [ uint256(IUserRegistry.KeyCode.EMISSION_LIMIT_KEY) ];
  uint256[] private receiverKeys = [ uint256(IUserRegistry.KeyCode.RECEPTION_LIMIT_KEY) ];

  // The definition below should be considered as a constant
  // Solidity 0.6.x do not provide ways to have arrays as constants
  bytes4[] public requiredCorePrivileges = [
    DEFINE_CORE_CONFIGURATION_PRIV,
    DEFINE_AUDIT_CONFIGURATION_PRIV,
    DEFINE_TOKEN_DELEGATE_PRIV,
    DEFINE_ROLE_PRIV,
    ASSIGN_OPERATORS_PRIV,
    REVOKE_OPERATORS_PRIV,
    ASSIGN_PROXY_OPERATORS_PRIV,
    DEFINE_ORACLE_PRIV
  ];

  /**
   * @dev has core access
   */
  function hasCoreAccess(ICore _core) override public view returns (bool access) {
    access = true;
    for (uint256 i=0; i<requiredCorePrivileges.length; i++) {
      access = access && _core.hasCorePrivilege(
        address(this), requiredCorePrivileges[i]);
    }
  }

   /**
   * @dev defineCoreConfigurations
   */
  function defineCoreConfigurations(
    ITokenCore _core,
    address[] calldata _factories,
    address _mintableDelegate,
    address _compliantDelegate,
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    address _currency
  ) override external onlyCoreOperator(_core) returns (bool)
  {
    require(hasCoreAccess(_core), "CC01");

    // Primary Market AML Configuration
    _core.defineAuditConfiguration(
      uint256(Configuration.AML_PRIMARY),
      uint256(ITokenStorage.Scope.DEFAULT),
      ITokenStorage.AuditTriggerMode.BOTH,
      emptyArray, receiverKeys, _ratesProvider, _currency
    );

    // Secondary Market AML Configuration
    _core.defineAuditConfiguration(
      uint256(Configuration.AML_FULL),
      uint256(ITokenStorage.Scope.DEFAULT),
      ITokenStorage.AuditTriggerMode.NONE,
      senderKeys, receiverKeys, _ratesProvider, _currency
    );

    _core.defineTokenDelegate(uint256(Delegate.UTILITY), _mintableDelegate, noAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.PAYMENT), _mintableDelegate, noAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.EQUITY), _compliantDelegate, secondaryMarketAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.BOND), _compliantDelegate, secondaryMarketAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.FUND), _compliantDelegate, secondaryMarketAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.DERIVATIVE), _compliantDelegate, secondaryMarketAMLConfig);
    _core.defineTokenDelegate(uint256(Delegate.SECURITY), _compliantDelegate, primaryMarketAMLConfig);

    // Setup basic roles
    bytes4[] memory privileges = new bytes4[](3);
    privileges[0] = ASSIGN_PROXY_OPERATORS_PRIV;
    privileges[1] = DEFINE_TOKEN_PRIV;
    privileges[2] = DEFINE_AUDIT_TRIGGERS_PRIV;
    _core.defineRole(FACTORY_CORE_ROLE, privileges);
    _core.assignOperators(FACTORY_CORE_ROLE, _factories);

    privileges = new bytes4[](5);
    privileges[0] = MINT_PRIV;
    privileges[1] = FINISH_MINTING_PRIV;
    privileges[2] = DEFINE_RULES_PRIV;
    privileges[3] = DEFINE_LOCK_PRIV;
    privileges[4] = DEFINE_TOKEN_LOCK_PRIV;
    _core.defineRole(FACTORY_PROXY_ROLE, privileges);
    _core.assignProxyOperators(ALL_PROXIES, FACTORY_PROXY_ROLE, _factories);

    privileges = new bytes4[](2);
    privileges[0] = DEFINE_TOKEN_PRIV;
    privileges[1] = APPROVE_TOKEN_PRIV;
    _core.defineRole(COMPLIANCE_CORE_ROLE, privileges);

    privileges = new bytes4[](5);
    privileges[0] = DEFINE_RULES_PRIV;
    privileges[1] = SEIZE_PRIV;
    privileges[2] = FREEZE_MANY_ADDRESSES_PRIV;
    privileges[3] = DEFINE_LOCK_PRIV;
    privileges[4] = DEPLOY_WRAPPED_TOKEN_PRIV;
    _core.defineRole(COMPLIANCE_PROXY_ROLE, privileges);

    privileges = new bytes4[](6);
    privileges[0] = MINT_PRIV;
    privileges[1] = BURN_PRIV;
    privileges[2] = FINISH_MINTING_PRIV;
    privileges[3] = DEFINE_LOCK_PRIV;
    privileges[4] = CONFIGURE_TOKENSALES_PRIV;
    privileges[5] = UPDATE_ALLOWANCE_PRIV;
    _core.defineRole(ISSUER_PROXY_ROLE, privileges);

    privileges = new bytes4[](1);
    privileges[0] = TRANSFER_FROM_PRIV;
    _core.defineRole(OPERATOR_PROXY_ROLE, privileges);

    // Assign Oracle
    _core.defineOracle(_userRegistry, _ratesProvider, _currency);

    address[] memory configOperators = new address[](1);
    configOperators[0] = address(this);
    _core.revokeOperators(configOperators);
    require(!hasCoreAccess(_core), "CC02");

    return true;
  }
}
