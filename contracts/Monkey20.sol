// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract Monkey20 is ERC20Upgradeable {
    error InvalidParameters();

    /**
     * @notice This function sets the initial states of the contract and is only called once at deployment.
     * @param _name The name of the token.
     * @param _symbol The symbol used to represent the token.
     */
    function initialize(string memory _name, string memory _symbol) public initializer {
        __ERC20_init(_name, _symbol);
    }

    function mintTo(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function mintToList(address[] memory _addresses, uint256[] memory _amounts) public {
        if (_addresses.length == 0 || _addresses.length != _amounts.length) revert InvalidParameters();

        for (uint256 i = 0; i < _addresses.length; ++i) {
            _mint(_addresses[i], _amounts[i]);
        }
    }
}
