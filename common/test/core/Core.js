'user strict';

/**
 * @author Cyril Lapinte - <cyril.lapinte@openfiz.com>
 */

const assertRevert = require('../helpers/assertRevert');
const DelegateMock = artifacts.require('DelegateMock.sol');
const Proxy = artifacts.require('Proxy.sol');
const Core = artifacts.require('Core.sol');

const NULL_ADDRESS = '0x'.padEnd(42, '0');
const STRING = 'TheAnswerToLife';
const BYTES = web3.utils.toHex('TheAnswerToLife').padEnd(66, '0');

contract('Core', function (accounts) {
  let core, coreAsDelegate, proxy, delegate;

  beforeEach(async function () {
    delegate = await DelegateMock.new();
    core = await Core.new([accounts[0]]);
    coreAsDelegate = await DelegateMock.at(core.address);
    proxy = await Proxy.new(core.address);
  });

  it('should define a delegate', async function () {
    const tx = await core.defineDelegate(1, delegate.address);
    assert.ok(tx.receipt.status, 'Status');
  });

  describe('With a delegate defined', async function () {
    beforeEach(async function () {
      await core.defineDelegate(1, delegate.address);
    });

    it('should un-define a delegate', async function () {
      const tx = await core.defineDelegate(1, NULL_ADDRESS);
      assert.ok(tx.receipt.status, 'Status');
    });

    it('should define a proxy', async function () {
      const tx = await core.defineProxy(proxy.address, 1);
      assert.ok(tx.receipt.status, 'Status');
    });

    it('should prevent defining a null proxy', async function () {
      await assertRevert(core.defineProxy(NULL_ADDRESS, 1), 'CO11');
    });

    it('should prevent define a proxy with a non existant delegate', async function () {
      await assertRevert(core.defineProxy(proxy.address, 2), 'CO10');
    });

    describe('With a fake proxy defined', async function () {
      beforeEach(async function () {
        await core.defineProxy(accounts[0], 1);
      });

      it('should delegate call actions', async function () {
        const success = await coreAsDelegate.delegateMockTxSuccess(true);
        assert.ok(success, 'success');
      });

      it('should delegate call view bool', async function () {
        const request = await delegate.delegateCallViewBoolMock.request(accounts[0], true);
        const success = await core.delegateCallView(request.data);
        assert.ok(success, 'success');
      });

      it('should delegate call view uint256', async function () {
        const request = await delegate.delegateCallViewUint256Mock.request(accounts[0], 42);
        const result = await core.delegateCallView(request.data).then((x) =>
          web3.eth.abi.decodeParameter('uint256', x),
        );
        assert.equal(result.toString(), '42', 'result');
      });

      it('should delegate call view bytes', async function () {
        const request = await delegate.delegateCallViewBytesMock.request(accounts[0], BYTES);
        const bytes = await core.delegateCallView(request.data);
        assert.equal(bytes.length, 194, 'bytes length');
        assert.ok(bytes.indexOf(BYTES.substr(2)) !== -1, 'bytes ends');
      });

      it('should delegate call view string', async function () {
        const request = await coreAsDelegate.delegateCallViewStringMock.request(accounts[0], STRING);
        const string = await core.delegateCallView(request.data).then((x) =>
          web3.eth.abi.decodeParameter('string', x),
        );
        assert.equal(string.length, STRING.length, 'length');
        assert.equal(string, STRING, 'string');
      });

      it('should delegate call uint256', async function () {
        const request = await delegate.staticCallUint256Mock.request(42);
        const result = await core.delegateCall.call(request.data).then((x) =>
          web3.eth.abi.decodeParameter('uint256', x),
        );
        assert.equal(result.toString(), '42', 'result');
      });

      it('should delegate call bytes', async function () {
        const request = await delegate.staticCallBytesMock.request(BYTES);
        const bytes = await core.delegateCall.call(request.data);
        assert.equal(bytes.length, 194, 'bytes length');
        assert.ok(bytes.indexOf(BYTES.substr(2)) !== -1, 'bytes ends');
      });

      it('should delegate call string', async function () {
        const request = await coreAsDelegate.staticCallStringMock.request(STRING);
        const string = await core.delegateCall.call(request.data).then((x) =>
          web3.eth.abi.decodeParameter('string', x),
        );
        assert.equal(string.length, STRING.length, 'length');
        assert.equal(string, STRING, 'string');
      });
    });

    describe('With an actual proxy defined', async function () {
      beforeEach(async function () {
        await core.defineProxy(proxy.address, 1);
      });

      it('should let the core migrate the proxy', async function () {
        const success = await core.migrateProxy(proxy.address, accounts[1]);
        assert.ok(success, 'success');

        const newCore = await proxy.core();
        assert.equal(newCore, accounts[1]);
      });

      it('should prevent to migrate a non existing proxy', async function () {
        await assertRevert(core.migrateProxy(accounts[0], accounts[1]), 'CO12');
      });

      it('should let the core remove the proxy', async function () {
        const success = await core.removeProxy(proxy.address);
        assert.ok(success, 'success');
      });

      it('should prevent to remove a non existing proxy', async function () {
        await assertRevert(core.removeProxy(accounts[1]), 'CO12');
      });
    });
  });
});
