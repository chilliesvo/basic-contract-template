//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";

contract Monkey721FreeClaim is ERC721HolderUpgradeable, OwnableUpgradeable {
    IERC721Upgradeable public token;

    /// @dev Mapping from token-id to claimer address.
    mapping(uint256 => address) public claimerAddresses;

    // ============ ERRORS ============

    error InvalidParams();
    error AddressIsZero();
    error NotClaimer();

    // ============ EVENTS ============

    /// @dev Emit an event when addTokensToClaimers success.
    event AddTokensToClaimers(address[] receivers, uint256[] tokenIds);

    /// @dev Emit an event when claim success.
    event Claim(address indexed claimer, uint256[] tokenIds);

    /**
     * @notice Setting states initial when deploy contract and only called once.
     * @param _owner The address of contract owner.
     * @param _tokenAddress The token address for the distribution Monkey721.
     */
    function initialize(address _owner, address _tokenAddress) external initializer {
        __Ownable_init();
        transferOwnership(_owner);
        token = IERC721Upgradeable(_tokenAddress);
    }

    /**
     * @notice Adds tokens to claimers.
     * @param _receivers The addresses of the receivers.
     * @param _tokenIds The IDs of the tokens to be added.
     */
    function addTokensToClaimers(address[] memory _receivers, uint256[] memory _tokenIds) external onlyOwner {
        if (_receivers.length != _tokenIds.length) revert InvalidParams();

        for (uint256 i = 0; i < _receivers.length; ++i) {
            if (_receivers[i] == address(0)) revert AddressIsZero();

            claimerAddresses[_tokenIds[i]] = _receivers[i];
            token.safeTransferFrom(_msgSender(), address(this), _tokenIds[i]);
        }

        emit AddTokensToClaimers(_receivers, _tokenIds);
    }

    /**
     * @notice Claims tokens for the caller.
     * @param _tokenIds The IDs of the tokens to be claimed.
     */
    function claim(uint256[] memory _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            if (claimerAddresses[_tokenIds[i]] != _msgSender()) revert NotClaimer();

            claimerAddresses[_tokenIds[i]] = address(0);
            token.safeTransferFrom(address(this), _msgSender(), _tokenIds[i]);
        }

        emit Claim(_msgSender(), _tokenIds);
    }
}
