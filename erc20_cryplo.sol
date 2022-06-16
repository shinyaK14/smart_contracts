// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

contract CryploToken is ERC20, Ownable {
  constructor () public ERC20("Jabba test Token", "JBT") {
    _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
  }

  function bulksendToken(address[] memory _to, uint256[] memory _values) onlyOwner public payable {
    require(_to.length == _values.length);

    for (uint256 i = 0; i < _to.length; i++) {
      transfer( _to[i], _values[i]);
    }
  }
}

