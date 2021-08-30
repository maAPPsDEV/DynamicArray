// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing dynamic array of primitive types.
 *
 * Dynamic array of type `bytes32` (`Bytes32Array`), `address` (`AddressArray`)
 * and `uint256` (`UintArray`) are supported.
 */
library DynamicArray {
  // To implement this library for multiple types with as little code
  // repetition as possible, we write it in terms of a generic Array type with
  // bytes32 values.
  // The Array implementation uses private functions, and user-facing
  // implementations (such as AddressArray) are just wrappers around the
  // underlying Array.
  // This means that we can only create new DynamicArrays for types that fit
  // in bytes32.

  struct Array {
    // The representative size of the array.
    uint256 _length;
    // The storage of array data. The length of storage may be different with above one.
    // The length of data is always greater than or equal above one.
    // The length of data is the capacity of array.
    bytes32[] _data;
  }

  /**
   * @dev Overwrites position in array with value.
   *
   * Reverts if position is out of bounds.
   */
  function _set(
    Array storage array,
    uint256 position,
    bytes32 value
  ) private {
    require(array._length > position, "DynamicArray: index out of bounds");
    array._data[position] = value;
  }

  /**
   * @dev Returns value at position in array.
   *
   * Reverts if position is out of bounds.
   */
  function _get(Array storage array, uint256 position) private view returns (bytes32) {
    require(array._length > position, "DynamicArray: index out of bounds");
    return array._data[position];
  }

  /**
   * @dev Adds value to end of array, and increases the array size.
   *
   * Reverts on overflow
   */
  function _push(Array storage array, bytes32 value) private {
    uint256 length = array._length; // gas saving
    if (array._data.length > length) {
      // If the data has occupied the position, just overwrite it.
      array._data[length] = value;
    } else {
      array._data.push(value);
    }
    // increase the array size.
    unchecked {
      // v0.8 adjustment
      length++;
    }
    require(length > 0, "DynamicArray: index overflow");
    array._length = length;
  }

  /**
   * @dev Removes and returns value at end of array, decreases array size
   *
   * Reverts on underflow.
   */
  function _pop(Array storage array) private returns (bytes32 last) {
    uint256 length = array._length; // gas saving
    require(length > 0, "DynamicArray: index underflow");
    last = array._data[length - 1];
    // underflow safe
    array._length--;
  }

  /**
   * @dev Returns the current size of array.
   */
  function _size(Array storage array) private view returns (uint256) {
    return array._length;
  }

  /**
   * @dev Returns the total storage size of array.
   */
  function _capacity(Array storage array) private view returns (uint256) {
    return array._data.length;
  }

  /**
   * @dev Sets size of array to 0.
   * It doesn't release storage.
   */
  function _clear(Array storage array) private {
    array._length = 0;
  }

  /**
   * @dev Deletes stale items as many as sufficient gas is available.
   * This is the only time data is deleted on storage.
   */
  function _shrink(Array storage array, uint256 gasTolerance) private {
    assembly {
      let length_ := sload(array.slot)
      let data_ := add(array.slot, 0x01)
      let capacity_ := sload(data_)
      let occupied_ := sub(capacity_, length_) // never underflow
      if eq(occupied_, 0) {
        return(0, 0)
      }
      if gt(
        number(),
        0xC5D488 /* @dev FIXME London Fork Block Number */
      ) {
        sstore(data_, length_)
        /// @dev No gas refunds since London Fork, thus just returns
        return(0, 0)
      }
      mstore(0, data_)
      let offset_ := keccak256(0, 0x20) // never greater than 2**256 - 1
      /// @notice calculating storage slot of array element can overflow, since storage has 2**256 slots.
      /// i.e. let end := add(offset, capacity) // can be greater than 2**256 - 1 aka. overflow
      /// Thus, it cannot use slot number as the loop iterator.
      /// Due to the nature, seemgly inefficient loop here 🤔
      let index_ := capacity_
      let gasLimit_ := add(gasTolerance, 20050) /// @dev FIXME add more for gracefully end up process, ref: https://github.com/crytic/evm-opcodes
      for {

      } gt(index_, length_) {
        index_ := sub(index_, 1)
      } {
        /// @dev check available remaining gas
        if lt(gas(), gasLimit_) {
          break
        }
        /// @notice Provability of overflow/underflow, but this is designed as storage is continuum.
        let slot := add(offset_, sub(index_, 1))
        sstore(slot, 0)
      }
      sstore(data_, index_) // update capacity
    }
  }

  // Bytes32Array

  struct Bytes32Array {
    Array _inner;
  }

  /**
   * @dev Overwrites position in array with value.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   * @param value     The value to write
   */
  function set(
    Bytes32Array storage array,
    uint256 position,
    bytes32 value
  ) internal {
    _set(array._inner, position, value);
  }

  /**
   * @dev Returns value at position in array.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   *
   * @return The value of the position in array.
   */
  function get(Bytes32Array storage array, uint256 position) internal view returns (bytes32) {
    return _get(array._inner, position);
  }

  /**
   * @dev Adds value to end of array, and increases the array size.
   *
   * Reverts on overflow
   *
   * @param array     The array struct
   * @param value     The value to append
   */
  function push(Bytes32Array storage array, bytes32 value) internal {
    _push(array._inner, value);
  }

  /**
   * @dev Removes and returns value at end of array, decreases array size
   *
   * Reverts on underflow.
   *
   * @param array     The array struct
   *
   * @return The value removed.
   */
  function pop(Bytes32Array storage array) internal returns (bytes32) {
    return _pop(array._inner);
  }

  /**
   * @dev Returns the current size of array.
   *
   * @param array     The array struct
   *
   * @return The size of array.
   */
  function size(Bytes32Array storage array) internal view returns (uint256) {
    return _size(array._inner);
  }

  /**
   * @dev Returns the total storage size of array.
   *
   * @param array     The array struct
   *
   * @return The storage capacity of array.
   */
  function capacity(Bytes32Array storage array) internal view returns (uint256) {
    return _capacity(array._inner);
  }

  /**
   * @dev Sets size of array to 0.
   * It doesn't release storage.
   *
   * @param array     The array struct
   */
  function clear(Bytes32Array storage array) internal {
    _clear(array._inner);
  }

  /**
   * @dev Deletes stale items.
   * This is the only time data is deleted on storage.
   *
   * @param array         The array struct
   * @param gasTolerance  The minimal gas amount should remain to prevent infinite loop
   */
  function shrink(Bytes32Array storage array, uint256 gasTolerance) internal {
    _shrink(array._inner, gasTolerance);
  }

  // UintArray

  struct UintArray {
    Array _inner;
  }

  /**
   * @dev Overwrites position in array with value.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   * @param value     The value to write
   */
  function set(
    UintArray storage array,
    uint256 position,
    uint256 value
  ) internal {
    _set(array._inner, position, bytes32(value));
  }

  /**
   * @dev Returns value at position in array.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   *
   * @return The value of the position in array.
   */
  function get(UintArray storage array, uint256 position) internal view returns (uint256) {
    return uint256(_get(array._inner, position));
  }

  /**
   * @dev Adds value to end of array, and increases the array size.
   *
   * Reverts on overflow
   *
   * @param array     The array struct
   * @param value     The value to append
   */
  function push(UintArray storage array, uint256 value) internal {
    _push(array._inner, bytes32(value));
  }

  /**
   * @dev Removes and returns value at end of array, decreases array size
   *
   * Reverts on underflow.
   *
   * @param array     The array struct
   *
   * @return The value removed.
   */
  function pop(UintArray storage array) internal returns (uint256) {
    return uint256(_pop(array._inner));
  }

  /**
   * @dev Returns the current size of array.
   *
   * @param array     The array struct
   *
   * @return The size of array.
   */
  function size(UintArray storage array) internal view returns (uint256) {
    return _size(array._inner);
  }

  /**
   * @dev Returns the total storage size of array.
   *
   * @param array     The array struct
   *
   * @return The storage capacity of array.
   */
  function capacity(UintArray storage array) internal view returns (uint256) {
    return _capacity(array._inner);
  }

  /**
   * @dev Sets size of array to 0.
   * It doesn't release storage.
   *
   * @param array     The array struct
   */
  function clear(UintArray storage array) internal {
    _clear(array._inner);
  }

  /**
   * @dev Deletes stale items.
   * This is the only time data is deleted on storage.
   *
   * @param array         The array struct
   * @param gasTolerance  The minimal gas amount should remain to prevent infinite loop
   */
  function shrink(UintArray storage array, uint256 gasTolerance) internal {
    _shrink(array._inner, gasTolerance);
  }

  // AddressArray

  struct AddressArray {
    Array _inner;
  }

  /**
   * @dev Overwrites position in array with value.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   * @param value     The value to write
   */
  function set(
    AddressArray storage array,
    uint256 position,
    address value
  ) internal {
    _set(array._inner, position, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Returns value at position in array.
   *
   * Reverts if position is out of bounds.
   *
   * @param array     The array struct
   * @param position  The position of the value to read
   *
   * @return The value of the position in array.
   */
  function get(AddressArray storage array, uint256 position) internal view returns (address) {
    return address(uint160(uint256(_get(array._inner, position))));
  }

  /**
   * @dev Adds value to end of array, and increases the array size.
   *
   * Reverts on overflow
   *
   * @param array     The array struct
   * @param value     The value to append
   */
  function push(AddressArray storage array, address value) internal {
    _push(array._inner, bytes32(uint256(uint160(value))));
  }

  /**
   * @dev Removes and returns value at end of array, decreases array size
   *
   * Reverts on underflow.
   *
   * @param array     The array struct
   *
   * @return The value removed.
   */
  function pop(AddressArray storage array) internal returns (address) {
    return address(uint160(uint256(_pop(array._inner))));
  }

  /**
   * @dev Returns the current size of array.
   *
   * @param array     The array struct
   *
   * @return The size of array.
   */
  function size(AddressArray storage array) internal view returns (uint256) {
    return _size(array._inner);
  }

  /**
   * @dev Returns the total storage size of array.
   *
   * @param array     The array struct
   *
   * @return The storage capacity of array.
   */
  function capacity(AddressArray storage array) internal view returns (uint256) {
    return _capacity(array._inner);
  }

  /**
   * @dev Sets size of array to 0.
   * It doesn't release storage.
   *
   * @param array     The array struct
   */
  function clear(AddressArray storage array) internal {
    _clear(array._inner);
  }

  /**
   * @dev Deletes stale items.
   * This is the only time data is deleted on storage.
   *
   * @param array         The array struct
   * @param gasTolerance  The minimal gas amount should remain to prevent infinite loop
   */
  function shrink(AddressArray storage array, uint256 gasTolerance) internal {
    _shrink(array._inner, gasTolerance);
  }
}
