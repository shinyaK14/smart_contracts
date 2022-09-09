// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

contract DeblogToken is ERC20, Ownable {
  constructor () ERC20("Deblog Token", "DEB") {
    _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
  }

  function contractURI() public pure returns (string memory) {
    return "https://static-files.pages.dev/deblog/metadata/token.json";
  }

  function bulksendToken(address[] memory _to, uint256[] memory _values) onlyOwner public payable {
    require(_to.length == _values.length);

    for (uint256 i = 0; i < _to.length; i++) {
      transfer( _to[i], _values[i]);
    }
  }
}

