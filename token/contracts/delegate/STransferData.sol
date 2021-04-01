pragma solidity ^0.8.0;

import "@c-layer/common/contracts/interface/IProxy.sol";


/**
 * @title STransferData
 * @dev STransferData structure
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
**/

struct STransferData {
  IProxy token;
  address caller;
  address sender;
  address receiver;

  uint256 senderId;
  uint256[] senderKeys;
  bool senderFetched;

  uint256 receiverId;
  uint256[] receiverKeys;
  bool receiverFetched;

  uint256 value;
  uint256 tokenId;
  uint256 convertedValue;
}
