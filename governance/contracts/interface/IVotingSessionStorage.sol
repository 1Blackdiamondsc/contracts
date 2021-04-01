pragma solidity ^0.8.0;

import "@c-layer/token/contracts/interface/ITokenERC20Proxy.sol";
import "@c-layer/token/contracts/interface/ITokenCore.sol";


/**
 * @title IVotingSessionStorage
 * @dev IVotingSessionStorage interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IVotingSessionStorage {

  enum SessionState {
    UNDEFINED,
    PLANNED,
    CAMPAIGN,
    VOTING,
    EXECUTION,
    GRACE,
    CLOSED,
    ARCHIVED
  }

  enum ProposalState {
    UNDEFINED,
    DEFINED,
    CANCELLED,
    LOCKED,
    APPROVED,
    REJECTED,
    RESOLVED,
    CLOSED,
    ARCHIVED
  }


  event SessionRuleUpdate(
    uint64 campaignPeriod,
    uint64 votingPeriod,
    uint64 executionPeriod,
    uint64 gracePeriod,
    uint64 periodOffset,
    uint8 openProposals,
    uint8 maxProposals,
    uint8 maxProposalsOperator,
    uint256 newProposalThreshold,
    address[] nonVotingAddresses);
  event ResolutionRequirementUpdate(
    address target,
    bytes4 methodSignature,
    uint128 majority,
    uint128 quorum,
    uint256 executionThreshold
  );

  event TokenDefinition(address token, address core);
  event DelegateDefinition(address delegate);

  event SponsorDefinition(address indexed voter, address address_, uint64 until);

  event SessionScheduled(uint256 indexed sessionId, uint64 voteAt);
  event SessionArchived(uint256 indexed sessionId);
  event ProposalDefinition(uint256 indexed sessionId, uint8 proposalId);
  event ProposalUpdate(uint256 indexed sessionId, uint8 proposalId);
  event ProposalCancelled(uint256 indexed sessionId, uint8 proposalId);
  event ResolutionExecution(uint256 indexed sessionId, uint8 proposalId);

  event Vote(uint256 indexed sessionId, address voter, uint256 weight);
}
