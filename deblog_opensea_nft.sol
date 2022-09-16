// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DeblogNFT is ERC1155, Ownable {
  mapping(uint256 => address) private minters;
  mapping(uint256 => bool) private transferredIds;

  constructor() ERC1155(""){ }

  function contractURI() public pure returns (string memory) {
    return "https://static-files.pages.dev/deblog/metadata/nft.json";
  }

  function mint(uint256 id, uint256 amount) public {
    require(minters[id] == address(0) || minters[id] == msg.sender);
    _mint(msg.sender, id, amount, "");

    if(minters[id] == address(0)) {
      minters[id] = msg.sender;
    }
  }

  function bulkMint(
    uint256 idOne, uint256 amountOne,
    uint256 idTwo, uint256 amountTwo,
    uint256 idThree, uint256 amountThree
  ) public payable {
    if(amountOne != 0) {
      mint(idOne, amountOne);
    }
    if(amountTwo != 0) {
      mint(idTwo, amountTwo);
    }
    if(amountThree != 0) {
      mint(idThree, amountThree);
    }
  }

  function burn(address account, uint256 id, uint256 amount) public {
    require(msg.sender == account);
    _burn(account,id,amount);
  }

  function uri(uint256 _id) override public pure returns (string memory) {
    return string(
      abi.encodePacked(
        "http://api.deblog.club/nft/metadatas/",
        Strings.toString(_id)
      )
    );
  }

  function getBalance() onlyOwner public view returns(uint) {
    return address(this).balance;
  }

  function withdrawToOwner() onlyOwner public payable {
    payable(owner()).transfer(address(this).balance);
  }

  function selfDestruct() onlyOwner public payable {
    selfdestruct(payable(owner()));
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override {
    for(uint256 i=0; i < ids.length; i++){
      require(!transferredIds[ids[i]]);
      transferredIds[ids[i]] = true;
    }
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
  }

}

