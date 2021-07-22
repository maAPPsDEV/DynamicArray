# DynamicArray

A Solidity Library for managing dynamic array of primitive types.

⚠️ Dynamic array of type `bytes32` (`Bytes32Array`), `address` (`AddressArray`) and `uint256` (`UintArray`) are supported.

## Description

The goal is to build a dynamically sized array similar to [C++ std::vector](https://en.cppreference.com/w/cpp/container/vector). Storage space is expensive on Ethereum; therefore, it is important to delete items when possible.

Write a Solidity library that implements “DynamicArray” with the following methods. You’ll have to fix the signatures to use the appropriate types and modifiers in Solidity. 
- `set(array, position, value)`: overwrite position in array with value
- `get(array, position)`: return value at position in array. Exception if position is out of bounds.
- `push(array, value)`: add value to end of array, increase array size
- `pop(array)`: remove and return value at end of array, decrease array size
- `size(array)`: return the current size of array
- `capacity(array)`: return the total storage size of array
- `clear(array)`: set size of array to 0
- `shrink(array)`: delete items from array until size == capacity. This is the only time data is deleted.

For example, if you push 10 values, then size == 10 and capacity == 10. If you pop 5 values, then size == 5, capacity == 10. If you try to get(array, 7) then that should raise an error because 7 exceeds the size, even though it is within the capacity.

For inspiration, take a look at [`EnumerableMap`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableMap.sol) and [`EnumerableSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol) from OpenZeppelin. Notice they use bytes32 as the underlying storage type, but expose type-specific functions for uint256 and address. 


## Usage

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../DynamicArray.sol";

contract AddressBook {
  using DynamicArray for DynamicArray.AddressArray;

  DynamicArray.AddressArray private book;

  function addAddress(address account) external {
    book.push(account);
  }

  function getAddressAt(uint256 index) external view returns (address) {
    return book.get(index);
  }

  function replaceAddressAt(uint256 index, address account) external {
    book.set(index, account);
  }

  function removeAddressAtLast() external returns (address) {
    return book.pop();
  }

  function numberOfAddresses() external view returns (uint256) {
    return book.size();
  }

  function sizeOfBook() external view returns (uint256) {
    return book.capacity();
  }

  function clearBook() external {
    book.clear();
  }

  function deleteBook() external {
    book.clear();
    book.shrink();
  }
}
```

## Development

### Configuration

```
npm install
```

### Test

```
npx hardhat test
```

```
  Contract: DynamicArray
    DynamicBytes32Array
      √ starts empty
      set
        √ reverts when setting at invalid position (54ms)
        √ overwrites an existing position (63ms)
      get
        √ reverts when getting at invalid position
        √ gets an existing position
      push
        √ adds at end (38ms)
        √ adds at end but doesn't occupy new storage when it's been occupied already (53ms)
      pop
        √ removes at end and doesn't delete storage
        √ reverts when popping in empty
      size
        √ returns size
        √ may be different with capacity
      capacity
        √ returns capacity
        √ may be different with size
      clear
        √ sets the size to 0, and doesn't delete storage
      shrink
        √ deletes stale storage (61ms)
    DynamicUintArray
      √ starts empty
      set
        √ reverts when setting at invalid position
        √ overwrites an existing position
      get
        √ reverts when getting at invalid position
        √ gets an existing position
      push
        √ adds at end
        √ adds at end but doesn't occupy new storage when it's been occupied already (43ms)
      pop
        √ removes at end and doesn't delete storage
        √ reverts when popping in empty
      size
        √ returns size
        √ may be different with capacity
      capacity
        √ returns capacity
        √ may be different with size
      clear
        √ sets the size to 0, and doesn't delete storage
      shrink
        √ deletes stale storage (49ms)
    DynamicAddressArray
      √ starts empty
      set
        √ reverts when setting at invalid position
        √ overwrites an existing position
      get
        √ reverts when getting at invalid position
        √ gets an existing position
      push
        √ adds at end
        √ adds at end but doesn't occupy new storage when it's been occupied already (44ms)
      pop
        √ removes at end and doesn't delete storage
        √ reverts when popping in empty
      size
        √ returns size
        √ may be different with capacity
      capacity
        √ returns capacity
        √ may be different with size
      clear
        √ sets the size to 0, and doesn't delete storage
      shrink
        √ deletes stale storage (50ms)


  45 passing (2s)
```
