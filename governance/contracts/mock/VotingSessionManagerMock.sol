pragma solidity ^0.8.0;

import "../voting/VotingSessionManager.sol";

/**
 * @title VotingSessionManager mock
 * @dev VotingSessionManager mock
 *
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 * SPDX-License-Identifier: MIT
 *
 * Error messages
 *   VMM01: Session has not started yet
 *   VMM02: Session is already archived
 **/
contract VotingSessionManagerMock is VotingSessionManager {

  /**
   * @dev constructor
   */
  constructor(ITokenERC20Proxy _token, IVotingSessionDelegate _delegate)
    VotingSessionManager(_token, _delegate) {
  }

  /**
   * @dev nextSessionStepTest
   */
  function nextSessionStepTest(uint256 _times) public returns (bool result) {
    result = nextStepTest(currentSessionId_);

    if(result) {
      return (_times > 1) ? nextSessionStepTest(_times - 1): result;
    }
  }

  /**
   * @dev nextStepTest
   */
  function nextStepTest(uint256 _sessionId) public returns (bool) {
    uint256 time = currentTime();

    SessionState state = this.sessionStateAt(_sessionId, time);
    Session storage session_ = sessions[_sessionId];

    require(state != SessionState.UNDEFINED, "VMM01");
    require(state != SessionState.ARCHIVED, "VMM02");
    uint256 voteAt = time;

    if (state == SessionState.PLANNED) {
      voteAt += (session_.voteAt - session_.campaignAt);
    }

    if (state == SessionState.CAMPAIGN) {
    }

    if (state == SessionState.VOTING) {
      voteAt -= (session_.executionAt - session_.voteAt);
    }

    if (state == SessionState.EXECUTION) {
      voteAt -= (session_.graceAt - session_.voteAt);
    }

    if (state == SessionState.GRACE) {
      voteAt -= (session_.closedAt - session_.voteAt);
    }

    if (state == SessionState.CLOSED) {
      voteAt -= SESSION_RETENTION_PERIOD;
    }

    session_.campaignAt = uint64(voteAt - sessionRule_.campaignPeriod);
    session_.voteAt = uint64(voteAt);
    session_.executionAt = uint64(voteAt + sessionRule_.votingPeriod);
    session_.graceAt = uint64(voteAt + sessionRule_.votingPeriod
      + sessionRule_.executionPeriod);
    session_.closedAt = uint64(voteAt + sessionRule_.votingPeriod
      + sessionRule_.executionPeriod + sessionRule_.gracePeriod);
    emit TestVoteAt(this.sessionStateAt(_sessionId, time), uint64(voteAt));
    return true;
  }

  /**
   * @dev historizeSessionTest
   */
  function historizeSessionTest() public returns (bool) {
    uint256 time = currentTime();
    SessionState state = this.sessionStateAt(currentSessionId_, time);
    Session storage session_ = sessions[currentSessionId_];

    require(state != SessionState.UNDEFINED, "VMM01");

    uint256 voteAt = time;
    voteAt -= (SESSION_RETENTION_PERIOD + 1);

    session_.campaignAt = uint64(voteAt - sessionRule_.campaignPeriod);
    session_.voteAt = uint64(voteAt);
    session_.executionAt = uint64(voteAt + sessionRule_.votingPeriod);
    session_.graceAt = uint64(voteAt + sessionRule_.votingPeriod
      + sessionRule_.executionPeriod);
    session_.closedAt = uint64(voteAt + sessionRule_.votingPeriod
      + sessionRule_.executionPeriod + sessionRule_.gracePeriod);
    emit TestVoteAt(this.sessionStateAt(currentSessionId_, time), uint64(voteAt));
    return true;
  }

  event TestVoteAt(SessionState state, uint64 voteAt);
}
