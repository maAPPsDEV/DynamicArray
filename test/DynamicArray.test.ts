import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, web3 } from "hardhat";

type MockArray = {
  length: number;
  capacity: number;
  items: string[];
};

function shouldBehaveLikeDynamicArray(values: string[]) {
  async function expectArrayMatch(array: Contract, { length, capacity, items }: MockArray) {
    expect(await array.size()).to.be.equal(length);
    expect(await array.capacity()).to.be.equal(capacity);
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
      await expect(this.array.set(0, values[0])).to.be.reverted;
    });

    it("overwrites an existing position", async function () {
      await this.array.push(values[0]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[0]],
      });
      await this.array.set(0, values[1]);
      await expectArrayMatch(this.array, {
        length: 1,
        capacity: 1,
        items: [values[1]],
      });
    });
  });

  describe("get", function () {
    it("reverts when getting at invalid position", async function () {
      await expect(this.array.get(0)).to.be.reverted;
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
      await expect(this.array.pop()).to.be.reverted;
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

describe("DynamicArray", function () {
  // Bytes32Array
  context("DynamicBytes32Array", function () {
    beforeEach(async function () {
      const factory = await ethers.getContractFactory("DynamicBytes32ArrayMock");
      const array = await factory.deploy();
      await array.deployed();
      this.array = array;
    });

    shouldBehaveLikeDynamicArray([web3.utils.randomHex(32), web3.utils.randomHex(32), web3.utils.randomHex(32)]);
  });

  // UintArray
  context("DynamicUintArray", function () {
    beforeEach(async function () {
      const factory = await ethers.getContractFactory("DynamicUintArrayMock");
      const array = await factory.deploy();
      await array.deployed();
      this.array = array;
    });

    shouldBehaveLikeDynamicArray(["123", "456", "789"]);
  });

  // AddressArray
  context("DynamicAddressArray", function () {
    beforeEach(async function () {
      const factory = await ethers.getContractFactory("DynamicAddressArrayMock");
      const array = await factory.deploy();
      await array.deployed();
      this.array = array;
    });

    shouldBehaveLikeDynamicArray([web3.utils.randomHex(20), web3.utils.randomHex(20), web3.utils.randomHex(20)]);
  });
});
