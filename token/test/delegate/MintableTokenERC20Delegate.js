'user strict';

/**
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */

const assertRevert = require('../helpers/assertRevert');
const TokenERC20Proxy = artifacts.require('TokenERC20Proxy.sol');
const TokenCore = artifacts.require('TokenCore.sol');
const MintableTokenERC20Delegate = artifacts.require('MintableTokenERC20Delegate.sol');

const AMOUNT = 1000000;
const NULL_ADDRESS = '0x'.padEnd(42, '0');
const NAME = 'Token';
const SYMBOL = 'TKN';
const DECIMALS = 18;

contract('MintableTokenERC20Delegate', function (accounts) {
  let core, coreAsDelegate, delegate, token;

  beforeEach(async function () {
    delegate = await MintableTokenERC20Delegate.new();
    core = await TokenCore.new('Test', [accounts[0]]);
    await core.defineTokenDelegate(1, delegate.address, []);

    token = await TokenERC20Proxy.new(core.address);
    await core.defineToken(
      token.address, 1, NAME, SYMBOL, DECIMALS);
    coreAsDelegate = await MintableTokenERC20Delegate.at(core.address);
  });

  it('should have no check configurations', async function () {
    const check = await delegate.checkConfigurations([]);
    assert.ok(check, 'check configurations');
  });

  it('should let operator mint', async function () {
    const recipients = [accounts[1], accounts[2], accounts[3]];
    const amounts = recipients.map((address, i) => AMOUNT * i);

    const tx = await coreAsDelegate.mint(token.address, recipients, amounts);

    assert.ok(tx.receipt.status, 'Status');
    assert.equal(tx.logs.length, 3);

    const tokenEvents = await token.getPastEvents('allEvents', {
      fromBlock: tx.logs[0].blockNumber,
      toBlock: tx.logs[0].blockNumber,
    });
    assert.equal(tokenEvents.length, 3, 'token events');

    recipients.forEach((address, i) => {
      assert.equal(tx.logs[i].event, 'MintERC20', 'event');
      assert.equal(tx.logs[i].args.amount, AMOUNT * i, 'amount');
      assert.equal(tokenEvents[i].event, 'Transfer', 'event');
      assert.equal(tokenEvents[i].returnValues.from, NULL_ADDRESS, 'from');
      assert.equal(tokenEvents[i].returnValues.to, address, 'to');
      assert.equal(tokenEvents[i].returnValues.value, AMOUNT * i, 'value');
    });
  });

  it('should prevent operator to mint with inconsistent parameters', async function () {
    await assertRevert(coreAsDelegate.mint(token.address, [accounts[1]], []), 'MT04');
  });

  it('should prevent non operator to mint', async function () {
    await assertRevert(
      coreAsDelegate.mint(token.address, [accounts[1]], [AMOUNT], { from: accounts[1] }),
      'CO03');
  });

  describe('With tokens minted', function () {
    beforeEach(async function () {
      await coreAsDelegate.mint(token.address, [accounts[1]], [AMOUNT]);
      await coreAsDelegate.mint(token.address, [accounts[2]], [2 * AMOUNT]);
    });

    it('should have a total supply', async function () {
      const supply = await token.totalSupply();
      assert.equal(supply.toString(), 3 * AMOUNT);
    });

    it('should not have finish minting', async function () {
      const request = await coreAsDelegate.token.request(token.address);
      const tokenData = await core.delegateCallView(request.data).then((x) =>
        web3.eth.abi.decodeParameters(
          ['bool', 'uint256', 'uint256', 'uint256', 'address[]', 'uint256', 'address[]'], x),
      );

      assert.ok(!tokenData[0], 'not mint finished');
    });

    it('should let operator finish minting', async function () {
      const tx = await coreAsDelegate.finishMinting(token.address);
      assert.ok(tx.receipt.status, 'Status');
      assert.equal(tx.logs.length, 1);
      assert.equal(tx.logs[0].event, 'MintFinish', 'event');
    });

    it('should prevent non operator to finish minting', async function () {
      await assertRevert(coreAsDelegate.finishMinting(token.address, { from: accounts[1] }), 'CO03');
    });

    describe('With operator having some tokens', async function () {
      beforeEach(async function () {
        await token.transfer(accounts[0], AMOUNT, { from: accounts[1] });
      });

      it('should let operator burn some tokens', async function () {
        const tx = await coreAsDelegate.burn(token.address, AMOUNT);
        assert.ok(tx.receipt.status, 'Status');
        assert.equal(tx.logs.length, 1);
        assert.equal(tx.logs[0].event, 'BurnERC20', 'event');
        assert.equal(tx.logs[0].args.token, token.address, 'token');
        assert.equal(tx.logs[0].args.amount, AMOUNT, 'amount');

        const tokenEvents = await token.getPastEvents('allEvents', {
          fromBlock: tx.logs[0].blockNumber,
          toBlock: tx.logs[0].blockNumber,
        });
        assert.equal(tokenEvents.length, 1, 'events');
        assert.equal(tokenEvents[0].event, 'Transfer', 'event');
        assert.equal(tokenEvents[0].returnValues.from, accounts[0], 'to');
        assert.equal(tokenEvents[0].returnValues.to, NULL_ADDRESS, 'from');
        assert.equal(tokenEvents[0].returnValues.value, AMOUNT, 'value');
      });

      it('should prevent operator to burn too many tokens', async function () {
        await assertRevert(coreAsDelegate.burn(token.address, AMOUNT + 1), 'MT02');
      });

      it('should prevent non operator to burn any tokens', async function () {
        await assertRevert(coreAsDelegate.burn(token.address, 1, { from: accounts[1] }), 'CO03');
      });
    });

    describe('With minting finished', function () {
      beforeEach(async function () {
        await coreAsDelegate.finishMinting(token.address);
      });

      it('should have finish minting', async function () {
        const request = await coreAsDelegate.token.request(token.address);
        const tokenData = await core.delegateCallView(request.data).then((x) =>
          web3.eth.abi.decodeParameters(
            ['bool', 'uint256', 'uint256', 'uint256', 'address[]', 'uint256', 'address[]'], x),
        );

        assert.ok(tokenData[0], 'mint finished');
      });

      it('should prevent operator to mint again', async function () {
        await assertRevert(coreAsDelegate.mint(token.address, [accounts[1]], [AMOUNT]), 'MT01');
      });

      it('should prevent operator to finish mintingt again', async function () {
        await assertRevert(coreAsDelegate.finishMinting(token.address), 'MT01');
      });
    });
  });
});
