// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DynamicArray.sol";

// Bytes32Array
contract DynamicBytes32ArrayMock {
  using DynamicArray for DynamicArray.Bytes32Array;

  DynamicArray.Bytes32Array private _array;

  function set(uint256 position, bytes32 value) public {
    _array.set(position, value);
  }

  function get(uint256 position) public view returns (bytes32) {
    return _array.get(position);
  }

  function push(bytes32 value) public {
    _array.push(value);
  }

  function pop() public returns (bytes32) {
    return _array.pop();
  }

  function size() public view returns (uint256) {
    return _array.size();
  }

  function capacity() public view returns (uint256) {
    return _array.capacity();
  }

  function clear() public {
    _array.clear();
  }

  function shrink(uint256 gasTolerance) public {
    _array.shrink(gasTolerance);
  }
}

// UintArray
contract DynamicUintArrayMock {
  using DynamicArray for DynamicArray.UintArray;

  DynamicArray.UintArray private _array;

  function set(uint256 position, uint256 value) public {
    _array.set(position, value);
  }

  function get(uint256 position) public view returns (uint256) {
    return _array.get(position);
  }

  function push(uint256 value) public {
    _array.push(value);
  }

  function pop() public returns (uint256) {
    return _array.pop();
  }

  function size() public view returns (uint256) {
    return _array.size();
  }

  function capacity() public view returns (uint256) {
    return _array.capacity();
  }

  function clear() public {
    _array.clear();
  }

  function shrink(uint256 gasTolerance) public {
    _array.shrink(gasTolerance);
  }
}

// AddressArray
contract DynamicAddressArrayMock {
  using DynamicArray for DynamicArray.AddressArray;

  DynamicArray.AddressArray private _array;

  function set(uint256 position, address value) public {
    _array.set(position, value);
  }

  function get(uint256 position) public view returns (address) {
    return _array.get(position);
  }

  function push(address value) public {
    _array.push(value);
  }

  function pop() public returns (address) {
    return _array.pop();
  }

  function size() public view returns (uint256) {
    return _array.size();
  }

  function capacity() public view returns (uint256) {
    return _array.capacity();
  }

  function clear() public {
    _array.clear();
  }

  function shrink(uint256 gasTolerance) public {
    _array.shrink(gasTolerance);
  }
}
