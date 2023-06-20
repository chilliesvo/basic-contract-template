//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ClonesUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./libraries/Monkey721FreeClaim.sol";
import "./libraries/Monkey1155FreeClaim.sol";
import "./interfaces/INFTChecker.sol";

contract FreeClaimFactory is ContextUpgradeable {
    INFTChecker public nftChecker;

    address public libraryMonkey721FreeClaim;
    address public libraryMonkey1155FreeClaim;

    mapping(uint256 => address) public contractAddresses;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public lastId;

    // ============ ERRORS ============
    error AddressIsZero();

    // ============ EVENTS ============

    /// @dev Emit an event when the contract is deployed.
    event ContractDeployed(
        address nftCheckerAddress,
        address indexed libraryMonkey721FreeClaimAddress,
        address indexed libraryMonkey1155FreeClaimAddress
    );

    /// @dev Emit an event when the Monkey721FreeClaim is created.
    event CreateMonkey721FreeClaim(
        uint256 indexed id,
        address indexed owner,
        address indexed tokenDistribution,
        address contractDeployed
    );

    /// @dev Emit an event when the Monkey1155FreeClaim is created.
    event CreateMonkey1155FreeClaim(
        uint256 indexed id,
        address indexed owner,
        address indexed tokenDistribution,
        address contractDeployed
    );

    /// @dev Emit an event when the libraryMonkey721FreeClaim is updated.
    event SetLibraryMonkey721FreeClaim(address indexed oldAddress, address indexed newAddress);

    /// @dev Emit an event when the libraryMonkey1155FreeClaim is updated.
    event SetLibraryMonkey1155FreeClaim(address indexed oldAddress, address indexed newAddress);

    /**
     * @notice Setting states initial when deploy contract and only called once.
     * @param _libraryMonkey721FreeClaimAddress The Monkey721FreeClaim address has been deployed.
     * @param _libraryMonkey1155FreeClaimAddress The Monkey1155FreeClaim address has been deployed.
     */
    function initialize(
        address _nftCheckerAddress,
        address _libraryMonkey721FreeClaimAddress,
        address _libraryMonkey1155FreeClaimAddress
    ) external initializer {
        nftChecker = INFTChecker(_nftCheckerAddress);
        libraryMonkey721FreeClaim = _libraryMonkey721FreeClaimAddress;
        libraryMonkey1155FreeClaim = _libraryMonkey1155FreeClaimAddress;
        emit ContractDeployed(
            _nftCheckerAddress,
            _libraryMonkey721FreeClaimAddress,
            _libraryMonkey1155FreeClaimAddress
        );
    }

    // ============ OWNER-ONLY ADMIN FUNCTIONS =============

    /**
     * @notice Update the new Monkey721FreeClaim library address
     * @param _newAddress Library address
     */
    function setLibraryMonkey721FreeClaim(address _newAddress) external {
        if (_newAddress == address(0)) revert AddressIsZero();
        address oldAddress = libraryMonkey721FreeClaim;
        libraryMonkey721FreeClaim = _newAddress;
        emit SetLibraryMonkey721FreeClaim(oldAddress, _newAddress);
    }

    /**
     * @notice Update the new Monkey1155FreeClaim library address
     * @param _newAddress Library address
     */
    function setLibraryMonkey1155FreeClaim(address _newAddress) external {
        if (_newAddress == address(0)) revert AddressIsZero();
        address oldAddress = libraryMonkey1155FreeClaim;
        libraryMonkey1155FreeClaim = _newAddress;
        emit SetLibraryMonkey1155FreeClaim(oldAddress, _newAddress);
    }

    // ============ PUBLIC FUNCTIONS FOR CREATING =============

    /**
     * @notice Creates a new contract Monkey721FreeClaim.
     * @param _tokenAddress The address of the token contract.
     */
    function createMonkey721FreeClaim(address _tokenAddress) external {
        if (!nftChecker.isERC721(_tokenAddress)) revert InvalidToken();
        address deployedContract = _create(true, _msgSender(), _tokenAddress);
        emit CreateMonkey721FreeClaim(lastId.current(), _msgSender(), _tokenAddress, deployedContract);
    }

    /**
     * @notice Creates a new contract Monkey1155FreeClaim.
     * @param _tokenAddress The address of the token contract.
     */
    function createMonkey1155FreeClaim(address _tokenAddress) external {
        if (!nftChecker.isERC1155(_tokenAddress)) revert InvalidToken();
        address deployedContract = _create(false, _msgSender(), _tokenAddress);
        emit CreateMonkey1155FreeClaim(lastId.current(), _msgSender(), _tokenAddress, deployedContract);
    }

    function _create(bool _isSingle, address _owner, address _tokenAddress) private returns (address deployedContract) {
        lastId.increment();
        bytes32 salt = keccak256(abi.encodePacked(lastId.current()));

        if (_isSingle) {
            Monkey721FreeClaim _osb721FreeClaim = Monkey721FreeClaim(
                ClonesUpgradeable.cloneDeterministic(libraryMonkey721FreeClaim, salt)
            );
            _osb721FreeClaim.initialize(_owner, _tokenAddress);
            deployedContract = address(_osb721FreeClaim);
        } else {
            Monkey1155FreeClaim _osb1155FreeClaim = Monkey1155FreeClaim(
                ClonesUpgradeable.cloneDeterministic(libraryMonkey1155FreeClaim, salt)
            );
            _osb1155FreeClaim.initialize(_owner, _tokenAddress);
            deployedContract = address(_osb1155FreeClaim);
        }

        contractAddresses[lastId.current()] = deployedContract;
    }
}
