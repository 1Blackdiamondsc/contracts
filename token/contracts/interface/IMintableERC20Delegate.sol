pragma solidity ^0.8.0;

import "./ITokenERC20Proxy.sol";


/**
 * @title Mintable ERCC20 Delegate Interface
 * @dev Mintable ERC20 Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IMintableERC20Delegate {

  function burn(ITokenERC20Proxy _token, uint256 _amount) external returns (bool);
  function mint(ITokenERC20Proxy _token, address[] memory _recipients, uint256[] memory _amounts)
    external returns (bool success);
  function finishMinting(ITokenERC20Proxy _token)
    external returns (bool);

}
