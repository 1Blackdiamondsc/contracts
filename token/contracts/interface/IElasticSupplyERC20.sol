pragma solidity ^0.8.0;


/**
 * @title IElasticSupplyERC20 interface
 *
 * SPDX-License-Identifier: MIT
 */
interface IElasticSupplyERC20 {

  event ElasticityUpdate(uint256 value);

  function elasticity() external view returns (uint256);
  function defineElasticity(uint256 _elasticity) external returns (bool);
}
