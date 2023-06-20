//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "./interfaces/IMonkey721.sol";
import "./interfaces/IMonkey1155.sol";
import "./interfaces/INFTChecker.sol";

contract Gift is ContextUpgradeable {
    INFTChecker public nftChecker;
    address public signerWallet;

    error InvalidParams();
    error InvalidSignature();
    error InvalidAmount();

    event SetSignerWallet(address indexed oldSigner, address indexed newSigner);
    event Gifting(address indexed token, address indexed from, address[] to, uint256[] tokenIds);

    function initialize(address _nftCheckerAddress, address _signerAddress) external initializer {
        ContextUpgradeable.__Context_init();
        nftChecker = INFTChecker(_nftCheckerAddress);
        signerWallet = _signerAddress;
    }

    function setSignerWallet(address _newSigner) external {
        address oldSigner = _newSigner;
        signerWallet = _newSigner;
        emit SetSignerWallet(oldSigner, _newSigner);
    }

    function giftingNFTs(
        address _token,
        address[] memory _accounts,
        uint256[] memory _tokenIds,
        uint256[] memory amounts,
        bytes memory _signature
    ) external {
        if (!nftChecker.isNFT(_token)) revert InvalidToken();
        if (_tokenIds.length != _accounts.length && _tokenIds.length != amounts.length) revert InvalidParams();

        //verify signature
        bytes32 messageHash = keccak256(abi.encodePacked(_token, _accounts, _tokenIds, amounts));
        bytes32 digest = ECDSAUpgradeable.toEthSignedMessageHash(messageHash);
        if (ECDSAUpgradeable.recover(digest, _signature) != signerWallet) revert InvalidSignature();

        //transfer tokens
        if (nftChecker.isERC721(_token)) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                if (amounts[i] != 1) revert InvalidAmount();
                IMonkey721(_token).safeTransferFrom(_msgSender(), _accounts[i], _tokenIds[i]);
            }
        } else {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                if (amounts[i] == 0) revert InvalidAmount();
                IMonkey1155(_token).safeTransferFrom(_msgSender(), _accounts[i], _tokenIds[i], amounts[i], "");
            }
        }

        emit Gifting(_token, _msgSender(), _accounts, _tokenIds);
    }

    function giftingCash(
        address _token,
        address[] memory _accounts,
        uint256[] memory _amounts,
        bytes memory _signature
    ) external {
        if (_accounts.length != _amounts.length) revert InvalidParams();

        //verify signature
        bytes32 messageHash = keccak256(abi.encodePacked(_token, _accounts, _amounts));
        bytes32 digest = ECDSAUpgradeable.toEthSignedMessageHash(messageHash);
        if (ECDSAUpgradeable.recover(digest, _signature) != signerWallet) revert InvalidSignature();

        //transfer tokens
        for (uint256 i = 0; i < _accounts.length; i++) {
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(_token), _msgSender(), _accounts[i], _amounts[i]);
        }
    }
}
