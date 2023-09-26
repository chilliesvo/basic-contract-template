pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Test721AutoIncrementId is ERC721("Simple 721", "721") {
    uint256 public lastId;

    function mint(address _to) external {
        _mint(_to, ++lastId);
    }

    function safeMint(address _to) external {
        _safeMint(_to, ++lastId);
    }
}
