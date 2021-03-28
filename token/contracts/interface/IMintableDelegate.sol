pragma solidity ^0.8.0;


/**
 * @title Mintable Delegate Interface
 * @dev Mintable Delegate Interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
abstract contract IMintableDelegate {

  function burn(address _token, uint256 _amount) public virtual returns (bool);
  function mint(address _token, address[] memory _recipients, uint256[] memory _amounts)
    public virtual returns (bool success);
  function finishMinting(address _token)
    public virtual returns (bool);

}
