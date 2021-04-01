pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/IERC721.sol";
import "@c-layer/common/contracts/interface/IERC721Metadata.sol";
import "@c-layer/common/contracts/interface/IERC721Enumerable.sol";
import "@c-layer/common/contracts/interface/IProxy.sol";


/**
 * @title IToken ERC721 proxy
 * @dev Token proxy interface ERC721
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 */
interface ITokenERC721Proxy is IERC721, IERC721Metadata, IERC721Enumerable, IProxy {

  function canTransfer(address, address, uint256) external view returns (uint256);
  function emitTransfer(address _from, address _to, uint256 _value) external returns (bool);
  function emitApproval(address _owner, address _spender, uint256 _value) external returns (bool);
  function emitApprovalForAll(address _owner, address _operator, bool _approved) external returns (bool);
}
