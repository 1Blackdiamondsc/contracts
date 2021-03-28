'user strict';

/**
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */

const assertRevert = require('../helpers/assertRevert');
const BytesConvertMock = artifacts.require('BytesConvertMock.sol');

contract('BytesConvert', function (accounts) {
  let contract;

  beforeEach(async function () {
    contract = await BytesConvertMock.new();
  });

  it('should convert to uint256', async function () {
    const uint256 = await contract.toUint256('0x' + '1234'.padStart(64, '0'));
    assert.equal(uint256.toString(), parseInt('1234', 16).toString(), 'uint256');
  });

  it('should prevent convert to uint256 to small bytes', async function () {
    await assertRevert(contract.toUint256('0x1234'), 'BC01');
  });

  it('should prevent convert to uint256 to large bytes length', async function () {
    await assertRevert(contract.toUint256('0x' + '1234'.padStart(65, '0')), 'BC01');
  });

  it('should convert to bytes32', async function () {
    const bytes32 = await contract.toBytes32('0x1234');
    assert.equal(bytes32.toString(), '0x' + '1234'.padEnd(64, '0'), 'bytes32');
  });

  it('should convert 32 length bytes to bytes32', async function () {
    const bytes32 = await contract.toBytes32('0x1234'.padEnd(66, '0'));
    assert.equal(bytes32.toString(), '0x' + '1234'.padEnd(64, '0'), 'bytes32');
  });

  it('should prevent convert to large value to bytes32', async function () {
    await assertRevert(contract.toBytes32('0x1234'.padEnd(67, '0')), 'BC02');
  });

  it('should prevent extracting value from a too short source', async function () {
    const addressParam = accounts[0].substr(3);
    await assertRevert(contract.firstParameter('0x12345678' + addressParam), 'BC03');
  });

  it('should extract first parameter from source', async function () {
    const addressParam = accounts[0].substr(2).padStart(64, '0');
    const parameter = await contract.firstParameter('0x12345678' + addressParam);
    assert.equal(parameter, '0x' + addressParam.toLowerCase(), 'bytes32');
  });

  it('should extract value from a large source', async function () {
    const addressParam = accounts[0].substr(2).padStart(64, '0');
    const parameter = await contract.firstParameter('0x12345678' + addressParam + '1111');
    assert.equal(parameter, '0x' + addressParam.toLowerCase(), 'bytes32');
  });
});
