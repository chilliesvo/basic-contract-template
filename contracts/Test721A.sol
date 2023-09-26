pragma solidity ^0.8.4;

import "./ERC721A.sol";

contract Test721A is ERC721A("Azuki", "721A") {
    function mint(address _to, uint256 _quantity) external {
        _mint(_to, _quantity);
    }

    function safeMint(address _to, uint256 _quantity) external {
        _safeMint(_to, _quantity, "");
    }
}
