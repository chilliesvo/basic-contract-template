//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

contract Monkey1155FreeClaim is ERC1155HolderUpgradeable, OwnableUpgradeable {
    IERC1155Upgradeable public token;

    ///@dev Mapping from token-id and claimer address to token-amount.
    mapping(uint256 => mapping(address => uint256)) public claimerAmounts;

    // ============ ERRORS ============

    error InvalidParams();
    error AddressIsZero();
    error AmountIsZero(uint256 tokenId);
    error WithdrawalAmountExceedsCurrentBalance(uint256 tokenId, uint256 currentBalance, uint256 amountClaim);

    // ============ EVENTS ============

    /// @dev Emit an event when addTokensToClaimers success.
    event AddTokensToClaimers(address[] receivers, uint256[] tokenIds, uint256[] tokenAmounts);

    /// @dev Emit an event when claim success.
    event Claim(address indexed claimer, uint256[] tokenIds, uint256[] tokenAmounts);

    /**
     * @notice Setting states initial when deploy contract and only called once.
     * @param _owner The address of contract owner.
     * @param _tokenAddress The token address for the distribution Monkey1155.
     */
    function initialize(address _owner, address _tokenAddress) external initializer {
        __Ownable_init();
        transferOwnership(_owner);
        token = IERC1155Upgradeable(_tokenAddress);
    }

    /**
     * @notice Adds tokens to claimers.
     * @param _receivers The addresses of the receivers.
     * @param _tokenIds The IDs of the tokens to be added.
     * @param _tokenAmounts The amounts of the each tokenId to be added.
     */
    function addTokensToClaimers(
        address[] memory _receivers,
        uint256[] memory _tokenIds,
        uint256[] memory _tokenAmounts
    ) external onlyOwner {
        if (!(_receivers.length == _tokenIds.length && _tokenIds.length == _tokenAmounts.length)) {
            revert InvalidParams();
        }

        for (uint256 i = 0; i < _receivers.length; ++i) {
            if (_receivers[i] == address(0)) revert AddressIsZero();
            if (_tokenAmounts[i] == 0) revert AmountIsZero(_tokenIds[i]);

            claimerAmounts[_tokenIds[i]][_receivers[i]] += _tokenAmounts[i];
            token.safeTransferFrom(_msgSender(), address(this), _tokenIds[i], _tokenAmounts[i], "");
        }

        emit AddTokensToClaimers(_receivers, _tokenIds, _tokenAmounts);
    }

    /**
     * @notice Claims tokens for the caller.
     * @param _tokenIds The IDs of the tokens to be claimed.
     * @param _claimAmounts The amount of the each tokenId to be claimed.
     */
    function claim(uint256[] memory _tokenIds, uint256[] memory _claimAmounts) external {
        if (_tokenIds.length != _claimAmounts.length) revert InvalidParams();

        for (uint256 i = 0; i < _tokenIds.length; ++i) {
            uint256 _currentBalance = claimerAmounts[_tokenIds[i]][_msgSender()];

            if (_claimAmounts[i] == 0) {
                revert AmountIsZero(_tokenIds[i]);
            }
            if (_currentBalance < _claimAmounts[i]) {
                revert WithdrawalAmountExceedsCurrentBalance(_tokenIds[i], _currentBalance, _claimAmounts[i]);
            }

            claimerAmounts[_tokenIds[i]][_msgSender()] -= _claimAmounts[i];
            token.safeTransferFrom(address(this), _msgSender(), _tokenIds[i], _claimAmounts[i], "");
        }

        emit Claim(_msgSender(), _tokenIds, _claimAmounts);
    }
}
