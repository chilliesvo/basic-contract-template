pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Test721 is ERC721("Simple 721", "721") {
    function mint(address _to, uint256 _tokenId) external {
        _mint(_to, _tokenId);
    }

    function safeMint(address _to, uint256 _tokenId) external {
        _safeMint(_to, _tokenId);
    }
}
