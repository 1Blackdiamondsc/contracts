pragma solidity ^0.8.0;

import "@c-layer/token/contracts/TokenERC20Proxy.sol";

/**
 * @title Token Proxy mock
 * @dev Token Proxy mock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 **/
contract TokenERC20ProxyMock is TokenERC20Proxy {

  constructor(ITokenCore _core) TokenERC20Proxy(_core) { }
}
