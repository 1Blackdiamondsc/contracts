pragma solidity ^0.8.0;

import "../TokenStorage.sol";
import "../interface/ISeizableERC20Delegate.sol";


/**
 * @title SeizableERC20Delegate
 * @dev Token which allows owner to seize accounts
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 * ST01: Transfer events must be generated
 * ST02: Operator cannot seize itself
*/
abstract contract SeizableERC20Delegate is ISeizableERC20Delegate, TokenStorage {

  /**
   * @dev called by the owner to seize value from the account
   */
  function seize(
    ITokenERC20Proxy _token,
    address _account,
    uint256 _amount) external override returns (bool)
  {
    require(_account != msg.sender, "ST02");
    TokenData storage token = tokens[_token];

    token.balances[_account] = token.balances[_account] - _amount;
    token.balances[msg.sender] = token.balances[msg.sender] + _amount;
    token.allTimeSeized = token.allTimeSeized + _amount;

    require(
      _token.emitTransfer(_account, msg.sender, _amount),
      "ST01");
    emit SeizeERC20(_token, _account, _amount);
    return true;
  }
}
