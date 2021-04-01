pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/ICore.sol";
import "@c-layer/oracle/contracts/interface/IUserRegistry.sol";
import "@c-layer/oracle/contracts/interface/IRatesProvider.sol";
import "../interface/ITokenCore.sol";


/**
 * @title ICoreConfiguration
 * @dev ICoreConfiguration
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
interface ICoreConfiguration {

  enum Configuration {
    DEFAULT,
    AML_PRIMARY,
    AML_FULL
  }

  enum Delegate {
    UNDEFINED,
    UTILITY,
    PAYMENT,
    EQUITY,
    BOND,
    FUND,
    DERIVATIVE,
    SECURITY
  }

  function hasCoreAccess(ICore _core) external view returns (bool);
  function defineCoreConfigurations(
    ITokenCore _core,
    address[] calldata _factories,
    address _mintableDelegate,
    address _compliantDelegate,
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    address _currency
  ) external returns (bool);
}
