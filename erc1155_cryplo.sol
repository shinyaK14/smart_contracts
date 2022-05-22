// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";

contract NFTCryplo is ERC1155, Ownable, RoyaltiesV2Impl {
  mapping(uint256 => address) private minters;

  constructor() ERC1155(""){}

  uint MINT_PRICE = 1 ether;
  uint PREMIUM_MINT_PRICE = 5 ether;

  function contractURI() public pure returns (string memory) {
    return "https://cryplo-api.herokuapp.com/contract_metadata.json";
  }

  function mint(address account, uint256 id, uint256 amount) public {
    require(minters[id] == address(0) || minters[id] == msg.sender);
    if(minters[id] == address(0)) {
      minters[id] = msg.sender;
    }
    _mint(account,id,amount,"");
    setRoyalties(account, id);
  }

  function bulkMint(address account, uint256[] memory ids, uint256[] memory amount) public payable {
    if(ids.length > 2) {
      require(msg.value >= PREMIUM_MINT_PRICE, "Not enough MATIC");

      mint(account, ids[0], amount[0]);
      mint(account, ids[1], amount[1]);
      mint(account, ids[2], amount[2]);
    } else if(ids.length > 1) {
      require(msg.value >= MINT_PRICE, "Not enough MATIC");

      mint(account, ids[0], amount[0]);
      mint(account, ids[1], amount[1]);
    }else if(ids.length > 0) {
      mint(account, ids[0], amount[0]);
    }
  }

  function burn(address account,uint256 id,uint256 amount) public {
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

  function getBalance() public view returns(uint) {
    return address(this).balance;
  }

  function withdraw() onlyOwner public payable {
    payable(owner()).transfer(address(this).balance);
  }

  function selfDestruct() onlyOwner public payable {
    selfdestruct(payable(owner()));
  }

  function setRoyalties(
      address account,
      uint256 _tokenId
      ) private payable {
    LibPart.Part[] memory _royalties = new LibPart.Part[](2);
    _royalties[0].account = payable(owner());
    _royalties[0].value = 1000;
    _royalties[1].account = payable(account);
    _royalties[1].value = 6000;
    _saveRoyalties(_tokenId, _royalties);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC1155)
        returns (bool)
        {
        if (interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
        return true;
        }
        return super.supportsInterface(interfaceId);
        }

}

        // https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl
        //https://rinkeby.rarible.com/token/polygon/0x21c5FE54806cB616e3398dBBA94341F43afaB73b:2?tab=owners



