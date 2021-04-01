pragma solidity ^0.8.0;

import "./IVotingSessionStorage.sol";


/**
 * @title IVotingSessionDelegate
 * @dev IVotingSessionDelegate interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IVotingSessionDelegate is IVotingSessionStorage {

  function nextSessionAt(uint256 _time) external view returns (uint256 at);

  function sessionStateAt(uint256 _sessionId, uint256 _time) external view returns (SessionState);

  function newProposalThresholdAt(uint256 _sessionId, uint256 _proposalsCount)
    external view returns (uint256);

  function proposalApproval(uint256 _sessionId, uint8 _proposalId)
    external view returns (bool);

  function proposalStateAt(uint256 _sessionId, uint8 _proposalId, uint256 _time)
    external view returns (ProposalState);

  function updateSessionRule(
    uint64 _campaignPeriod,
    uint64 _votingPeriod,
    uint64 _executionPeriod,
    uint64 _gracePeriod,
    uint64 _periodOffset,
    uint8 _openProposals,
    uint8 _maxProposals,
    uint8 _maxProposalsQuaestor,
    uint256 _newProposalThreshold,
    address[] memory _nonVotingAddresses
  ) external;

  function updateResolutionRequirements(
    address[] memory _targets,
    bytes4[] memory _methodSignatures,
    uint128[] memory _majority,
    uint128[] memory _quorum,
    uint256[] memory _executionThreshold
  ) external;

  function defineProposal(
    string memory _name,
    string memory _url,
    bytes32 _proposalHash,
    address _resolutionTarget,
    bytes memory _resolutionAction,
    uint8 _dependsOn,
    uint8 _alternativeOf
  ) external;

  function updateProposal(
    uint8 _proposalId,
    string memory _name,
    string memory _url,
    bytes32 _proposalHash,
    address _resolutionTarget,
    bytes memory _resolutionAction,
    uint8 _dependsOn,
    uint8 _alternativeOf
  ) external;
  function cancelProposal(uint8 _proposalId) external;

  function submitVote(uint256 _votes) external;
  function submitVotesOnBehalf(
    address[] memory _voters,
    uint256 _votes
  ) external;

  function executeResolutions(uint8[] memory _proposalIds) external;
  function archiveSession() external;
}
