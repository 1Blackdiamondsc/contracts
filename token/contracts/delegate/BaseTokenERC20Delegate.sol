pragma solidity ^0.8.0;

import "../interface/IBaseTokenERC20Delegate.sol";
import "./STransferData.sol";
import "../TokenStorage.sol";
import "../TokenERC20Proxy.sol";


/**
 * @title Base Token Delegate
 * @dev Base Token Delegate
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 * TD01: Recipient must not be null or be a reserved address
 * TD02: Not enougth tokens
 * TD03: Transfer event must be generated
 * TD04: Allowance limit reached
 */
contract BaseTokenERC20Delegate is IBaseTokenERC20Delegate, TokenStorage {

  function name() external override view returns (string memory) {
    return tokens[ITokenERC20Proxy(msg.sender)].name;
  }

  function symbol() external override view returns (string memory) {
    return tokens[ITokenERC20Proxy(msg.sender)].symbol;
  }

  function decimals() virtual override public view returns (uint256) {
    return tokens[ITokenERC20Proxy(msg.sender)].decimals;
  }

  function totalSupply() virtual override public view returns (uint256) {
    return tokens[ITokenERC20Proxy(msg.sender)].totalSupply;
  }

  function balanceOf(address _owner) virtual override public view returns (uint256) {
    return tokens[ITokenERC20Proxy(msg.sender)].balances[_owner];
  }

  function allowance(address _owner, address _spender)
    virtual override public view returns (uint256)
  {
    return tokens[ITokenERC20Proxy(msg.sender)].erc20.allowances[_owner][_spender];
  }

  function token(IProxy _token) external override view returns (
    bool mintingFinished,
    uint256 allTimeMinted,
    uint256 allTimeBurned,
    uint256 allTimeSeized,
    address[] memory locks,
    uint256 frozenUntil,
    IRule[] memory rules) {
    TokenData storage tokenData = tokens[_token];

    mintingFinished = tokenData.mintingFinished;
    allTimeMinted = tokenData.allTimeMinted;
    allTimeBurned = tokenData.allTimeBurned;
    allTimeSeized = tokenData.allTimeSeized;
    locks = tokenData.locks;
    frozenUntil = tokenData.frozenUntils[address(_token)];
    rules = tokenData.rules;
  }

  /**
   * @dev Overriden transfer function
   */
  function transfer(address _sender, address _receiver, uint256 _value)
    virtual override public
  {
    transferInternal(
      transferData(ITokenERC20Proxy(msg.sender), address(0), _sender, _receiver, _value));
  }

  /**
   * @dev Overriden transferFrom function
   */
  function transferFrom(
    address _caller, address _sender, address _receiver, uint256 _value)
    virtual override public
  {
    transferInternal(
      transferData(ITokenERC20Proxy(msg.sender), _caller, _sender, _receiver, _value));
  }

  /**
   * @dev can transfer
   */
  function canTransfer(
    address _sender,
    address _receiver,
    uint256 _value) virtual override public view returns (TransferCode)
  {
    return canTransferInternal(
      transferData(ITokenERC20Proxy(msg.sender), address(0), _sender, _receiver, _value));
  }

  /**
   * @dev approve
   */
  function approve(address _sender, address _spender, uint256 _value)
    virtual override public
  {
    TokenData storage token_ = tokens[ITokenERC20Proxy(msg.sender)];
    token_.erc20.allowances[_sender][_spender] = _value;
    require(
      TokenERC20Proxy(msg.sender).emitApproval(_sender, _spender, _value),
      "TD03");
  }

  /**
   * @dev increase approval
   */
  function increaseApproval(address _sender, address _spender, uint _addedValue)
    virtual override public
  {
    TokenData storage token_ = tokens[ITokenERC20Proxy(msg.sender)];
    token_.erc20.allowances[_sender][_spender] = token_.erc20.allowances[_sender][_spender] + _addedValue;
    require(
      TokenERC20Proxy(msg.sender).emitApproval(_sender, _spender, token_.erc20.allowances[_sender][_spender]),
      "TD03");
  }

  /**
   * @dev decrease approval
   */
  function decreaseApproval(address _sender, address _spender, uint _subtractedValue)
    virtual override public
  {
    TokenData storage token_ = tokens[ITokenERC20Proxy(msg.sender)];
    uint oldValue = token_.erc20.allowances[_sender][_spender];
    if (_subtractedValue > oldValue) {
      token_.erc20.allowances[_sender][_spender] = 0;
    } else {
      token_.erc20.allowances[_sender][_spender] = oldValue - _subtractedValue;
    }
    require(
      TokenERC20Proxy(msg.sender).emitApproval(_sender, _spender, token_.erc20.allowances[_sender][_spender]),
      "TD03");
  }

  /**
   * @dev check configuration
   **/
  function checkConfigurations(uint256[] calldata) virtual override public pure returns (bool) {
    return true;
  }

  /**
   * @dev transfer
   */
  function transferInternal(STransferData memory _transferData)
    virtual internal returns (bool)
  {
    TokenData storage token_ = tokens[_transferData.token];
    address caller = _transferData.caller;
    address sender = _transferData.sender;
    address receiver = _transferData.receiver;
    uint256 value = _transferData.value;

    require(receiver != address(0) || receiver != ANY_ADDRESSES, "TD01");
    require(value <= token_.balances[sender], "TD02");

    emit LogAddressD(address(this));
    if (caller != address(0)
      && (selfManaged[sender]
        || !hasProxyPrivilegeInternal(caller, _transferData.token, msg.sig)))
    {
      require(value <= token_.erc20.allowances[sender][caller], "TD04");
      token_.erc20.allowances[sender][caller] -= value;
    }

    token_.balances[sender] -= value;
    token_.balances[receiver] += value;
    require(
      TokenERC20Proxy(msg.sender).emitTransfer(sender, receiver, value),
      "TD03");
    return true;
  }

  event LogAddressD(address a);

  /**
   * @dev can transfer
   */
  function canTransferInternal(STransferData memory _transferData)
    virtual internal view returns (TransferCode)
  {
    TokenData storage token_ = tokens[_transferData.token];
    address sender = _transferData.sender;
    address receiver = _transferData.receiver;
    uint256 value = _transferData.value;

    if (sender == address(0)) {
      return TransferCode.INVALID_SENDER;
    }

    if (receiver == address(0)) {
      return TransferCode.NO_RECIPIENT;
    }

    if (value > token_.balances[sender]) {
      return TransferCode.INSUFFICIENT_TOKENS;
    }

    return TransferCode.OK;
  }

  /**
   * @dev transferData
   */
  function transferData(
    ITokenERC20Proxy _token, address _caller,
    address _sender, address _receiver, uint256 _value)
    internal pure returns (STransferData memory)
  {
    uint256[] memory emptyArray = new uint256[](1);
    return STransferData(
        _token,
        _caller,
        _sender,
        _receiver,
        0,
        emptyArray,
        false,
        0,
        emptyArray,
        false,
        _value,
        0,
        0
    );
  }
}
