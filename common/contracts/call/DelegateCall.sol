pragma solidity ^0.8.0;


/**
 * @title DelegateCall
 * @dev Calls delegates for non view functions only
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error Messages:
 **/
library DelegateCall {

  bytes4 internal constant DELEGATE_CALL_SELECTOR = bytes4(keccak256("delegateCall(bytes)"));

  function _delegateCall(address _delegate, bytes calldata _data) internal returns (bytes memory result)
  {
    bool status;
    // solhint-disable-next-line avoid-low-level-calls
    (status, result) = _delegate.delegatecall(_data);
    require(status, string(result));
  }

  /**
   * @dev forward static call
   * @notice forward call to the delegate call core function
   * @notice this will erase compiler view restriction
   */
  function _forwardStaticCall(address _forward, bytes calldata _data) internal view returns (bytes memory result) {
    bool status;
    // solhint-disable-next-line avoid-low-level-calls
    (status, result) = _forward.staticcall(
      abi.encodeWithSelector(DELEGATE_CALL_SELECTOR, _data));
    require(status, string(result));
    result = abi.decode(result, (bytes));
  }
}
