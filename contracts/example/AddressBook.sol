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
    book.shrink(0);
  }
}
