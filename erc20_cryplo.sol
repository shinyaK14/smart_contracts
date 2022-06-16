import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


pragma solidity ^0.8.0;

contract Token is ERC20 {
  constructor () public ERC20("Jabba test Token", "JBT") {
    _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
  }
}
