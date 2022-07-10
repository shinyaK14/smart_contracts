// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";

contract NFTCryplo is ERC1155, Ownable, RoyaltiesV2Impl {
  mapping(uint256 => address) private minters;
  uint public mint_price  = 1 ether;
  uint public premium_mint_price = 5 ether;

  constructor() ERC1155(""){ }

  function contractURI() public pure returns (string memory) {
    return "https://cryplo-api.herokuapp.com/contract_metadata.json";
  }

  function mint(uint256 id, uint256 amount) public {
    require(minters[id] == address(0) || minters[id] == msg.sender);
    _mint(msg.sender, id, amount, "");

    if(minters[id] == address(0)) {
      minters[id] = msg.sender;
      _setRoyalties(id);
    }
  }

  function bulkMint(
    uint256 idOne, uint256 amountOne,
    uint256 idTwo, uint256 amountTwo,
    uint256 idThree, uint256 amountThree
  ) public payable {
    if(amountThree != 0) {
      require(msg.value >= premium_mint_price, "Not enough MATIC");
    } else if(amountTwo != 0){
      require(msg.value >= mint_price, "Not enough MATIC");
    }

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
        "https://cryplo-api.herokuapp.com/nft/metadatas/",
        Strings.toString(_id)
      )
    );
  }

  function getBalance() onlyOwner public view returns(uint) {
    return address(this).balance;
  }

  function withdraw() onlyOwner public payable {
    payable(owner()).transfer(address(this).balance);
  }

  function selfDestruct() onlyOwner public payable {
    selfdestruct(payable(owner()));
  }

  function _setRoyalties(uint256 _tokenId) private {
    LibPart.Part[] memory _royalties = new LibPart.Part[](2);
    _royalties[0].account = payable(owner());
    _royalties[0].value = 1000;
    _royalties[1].account = payable(msg.sender);
    _royalties[1].value = 3500;
    _saveRoyalties(_tokenId, _royalties);
  }

  function supportsInterface(bytes4 interfaceId)
    public view virtual override(ERC1155) returns (bool) {
    if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
      return true;
    }
    return super.supportsInterface(interfaceId);
  }

  function getMintPrice(uint mintPrice, uint preminumMintPrice) onlyOwner public {
    mint_price = mintPrice;
    premium_mint_price = preminumMintPrice;
  }

  function getMintPrice(uint256 _id) public view returns(uint) {
    if(_id == 0) {
      return mint_price;
    }

    return premium_mint_price;
  }
}

