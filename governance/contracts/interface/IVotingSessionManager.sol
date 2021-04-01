pragma solidity ^0.8.0;

import "@c-layer/common/contracts/operable/Ownable.sol";
import "@c-layer/token/contracts/interface/ITokenERC20Proxy.sol";
import "./IVotingSessionStorage.sol";
import "./IVotingSessionDelegate.sol";


/**
 * @title IVotingSessionManager
 * @dev IVotingSessionManager interface
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 */
interface IVotingSessionManager is IVotingSessionStorage {

  function contracts() external view returns (
    IVotingSessionDelegate delegate, ITokenERC20Proxy token, ITokenCore core);

  function sessionRule() external view returns (
    uint64 campaignPeriod,
    uint64 votingPeriod,
    uint64 executionPeriod,
    uint64 gracePeriod,
    uint64 periodOffset,
    uint8 openProposals,
    uint8 maxProposals,
    uint8 maxProposalsOperator,
    uint256 newProposalThreshold,
    address[] memory nonVotingAddresses);

  function resolutionRequirement(address _target, bytes4 _method) external view returns (
    uint128 majority,
    uint128 quorum,
    uint256 executionThreshold);

  function oldestSessionId() external view returns (uint256);

  function currentSessionId() external view returns (uint256);

  function session(uint256 _sessionId) external view returns (
    uint64 campaignAt,
    uint64 voteAt,
    uint64 executionAt,
    uint64 graceAt,
    uint64 closedAt,
    uint256 sessionProposalsCount,
    uint256 participation,
    uint256 totalSupply,
    uint256 circulatingSupply);

  function proposal(uint256 _sessionId, uint8 _proposalId) external view returns (
    string memory name,
    string memory url,
    bytes32 proposalHash,
    address resolutionTarget,
    bytes memory resolutionAction);
  function proposalData(uint256 _sessionId, uint8 _proposalId) external view returns (
    address proposedBy,
    uint128 requirementMajority,
    uint128 requirementQuorum,
    uint256 executionThreshold,
    uint8 dependsOn,
    uint8 alternativeOf,
    uint256 alternativesMask,
    uint256 approvals);

  function sponsorOf(address _voter) external view returns (address sponsor, uint64 until);

  function lastVoteOf(address _voter) external view returns (uint64 at);

  function nextSessionAt(uint256 _time) external view returns (uint256 at);

  function sessionStateAt(uint256 _sessionId, uint256 _time) external view returns (SessionState);

  function newProposalThresholdAt(uint256 _sessionId, uint256 _proposalsCount)
    external view returns (uint256);

  function proposalApproval(uint256 _sessionId, uint8 _proposalId)
    external view returns (bool);

  function proposalStateAt(uint256 _sessionId, uint8 _proposalId, uint256 _time)
    external view returns (ProposalState);

  function defineContracts(ITokenERC20Proxy _token, IVotingSessionDelegate _delegate)
    external;

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

  function defineSponsor(address _sponsor, uint64 _until) external;
  function defineSponsorOf(Ownable _contract, address _sponsor, uint64 _until)
    external;

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
