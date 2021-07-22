const { expectEvent, expectRevert, BN } = require("@openzeppelin/test-helpers");
const { expect } = require("chai");

const DynamicBytes32ArrayMock = artifacts.require("DynamicBytes32ArrayMock");
const DynamicUintArrayMock = artifacts.require("DynamicUintArrayMock");
const DynamicAddressArrayMock = artifacts.require("DynamicAddressArrayMock");

function shouldBehaveLikeDynamicArray(values) {
  async function expectArrayMatch(array, { length, capacity, items }) {
    expect(await array.size()).to.be.bignumber.equal(new BN(length));
    expect(await array.capacity()).to.be.bignumber.equal(new BN(capacity));
    expect(
      (await Promise.all(Array.from(Array(length)).map((_, i) => array.get(i)))).map((item) => item.toString().toLowerCase()),
    ).to.deep.equal(items);
  }

  it("starts empty", async function () {
    expectArrayMatch(this.array, {
      length: 0,
      capacity: 0,
      items: [],
    });
  });

  describe("set", function () {
    it("reverts when setting at invalid position", async function () {
      await expectRevert.unspecified(this.array.set(0, values[0]));
    });

    it("overwrites an existing position", async function () {
      await this.array.push(values[0]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[0]],
      });
      const result = await this.array.set(0, values[1]);
      expect(result.receipt.status).to.be.equal(true);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[1]],
      });
    });
  });

  describe("get", function () {
    it("reverts when getting at invalid position", async function () {
      await expectRevert.unspecified(this.array.get(0));
    });

    it("gets an existing position", async function () {
      await this.array.push(values[0]);
      expect((await this.array.get(0)).toString().toLowerCase()).to.be.equal(values[0]);
    });
  });

  describe("push", function () {
    it("adds at end", async function () {
      await this.array.push(values[0]);
      await this.array.push(values[1]);
      await expectArrayMatch(this.array, {
        length: 2,
        capacity: 2,
        items: [values[0], values[1]],
      });
    });

    it("adds at end but doesn't occupy new storage when it's been occupied already", async function () {
      await this.array.push(values[0]);
      await this.array.push(values[1]);
      await this.array.pop();
      await this.array.pop();
      await this.array.push(values[0]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 2,
        items: [values[0]],
      });
    });
  });

  describe("pop", function () {
    it("removes at end and doesn't delete storage", async function () {
      await this.array.push(values[0]);
      await this.array.pop();
      await expectArrayMatch(this.array, {
        length: 0,
        capacity: 1,
        items: [],
      });
    });

    it("reverts when popping in empty", async function () {
      await expectRevert.unspecified(this.array.pop());
    });
  });

  describe("size", function () {
    it("returns size", async function () {
      await this.array.push(values[0]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[0]],
      });
    });

    it("may be different with capacity", async function () {
      await this.array.push(values[0]);
      await this.array.pop();
      await expectArrayMatch(this.array, {
        length: 0,
        capacity: 1,
        items: [],
      });
    });
  });

  describe("capacity", function () {
    it("returns capacity", async function () {
      await this.array.push(values[0]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[0]],
      });
    });

    it("may be different with size", async function () {
      await this.array.push(values[0]);
      await this.array.pop();
      await expectArrayMatch(this.array, {
        length: 0,
        capacity: 1,
        items: [],
      });
    });
  });

  describe("clear", function () {
    it("sets the size to 0, and doesn't delete storage", async function () {
      await this.array.push(values[0]);
      await this.array.clear();
      await expectArrayMatch(this.array, {
        length: 0,
        capacity: 1,
        items: [],
      });
    });
  });

  describe("shrink", function () {
    it("deletes stale storage", async function () {
      await this.array.push(values[0]);
      await this.array.push(values[1]);
      await this.array.push(values[2]);
      await this.array.pop();
      await this.array.pop();
      await this.array.shrink();
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[0]],
      });
    });
  });
}

contract("DynamicArray", function (accounts) {
  // Bytes32Array
  describe("DynamicBytes32Array", function () {
    beforeEach(async function () {
      this.array = await DynamicBytes32ArrayMock.new();
    });

    shouldBehaveLikeDynamicArray([web3.utils.randomHex(32), web3.utils.randomHex(32), web3.utils.randomHex(32)]);
  });

  // UintArray
  describe("DynamicUintArray", function () {
    beforeEach(async function () {
      this.array = await DynamicUintArrayMock.new();
    });

    shouldBehaveLikeDynamicArray(["123", "456", "789"]);
  });

  // AddressArray
  describe("DynamicAddressArray", function () {
    beforeEach(async function () {
      this.array = await DynamicAddressArrayMock.new();
    });

    shouldBehaveLikeDynamicArray([web3.utils.randomHex(20), web3.utils.randomHex(20), web3.utils.randomHex(20)]);
  });
});
