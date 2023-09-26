pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Test721Enumerable is ERC721Enumerable {
    uint256 public lastId;

    constructor() ERC721("Simple", "721") {}

    function mint(address _to) external {
        _mint(_to, ++lastId);
    }

    function safeMint(address _to) external {
        _safeMint(_to, ++lastId);
    }
}
