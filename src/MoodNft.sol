// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title MoodNft
 * @author Your Name
 * @notice This contract implements a mood-based NFT where the image changes based on the token's mood state
 * @dev Inherits from OpenZeppelin's ERC721 and Ownable contracts
 * The NFT metadata is stored entirely on-chain using base64-encoded SVG images
 */
contract MoodNft is ERC721, Ownable {
    error MoodNft__CantFlipMoodIfNotOwner();

    enum NFTState {
        HAPPY,
        SAD
    }

    uint256 private s_tokenCounter;
    string private s_sadSvgUri;
    string private s_happySvgUri;

    mapping(uint256 => NFTState) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    /**
     * @notice Constructor to initialize the MoodNft contract
     * @param sadSvgUri Base64-encoded data URI for the sad mood SVG
     * @param happySvgUri Base64-encoded data URI for the happy mood SVG
     */

    constructor(
        string memory sadSvgUri,
        string memory happySvgUri
    ) ERC721("Mood NFT", "MN") Ownable(msg.sender) {
        s_tokenCounter = 0;
        s_sadSvgUri = sadSvgUri;
        s_happySvgUri = happySvgUri;
    }

    /**
     * @notice Mints a new MoodNft to the caller
     * @dev The NFT starts in a HAPPY state by default
     * Emits a CreatedNFT event with the new token ID
     */
    function mintNft() public {
        // how would you require payment for this NFT?
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedNFT(tokenCounter);
    }

    /**
     * @notice Flips the mood of a specific NFT between HAPPY and SAD
     * @param tokenId The ID of the token whose mood should be flipped
     * @dev Only the token owner, approved address, or approved operator can flip the mood
     * Reverts with MoodNft__CantFlipMoodIfNotOwner if caller is not authorized
     */

    function flipMood(uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        if (
            getApproved(tokenId) != msg.sender &&
            owner != msg.sender &&
            !isApprovedForAll(owner, msg.sender)
        ) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToState[tokenId] == NFTState.HAPPY) {
            s_tokenIdToState[tokenId] = NFTState.SAD;
        } else {
            s_tokenIdToState[tokenId] = NFTState.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireOwned(tokenId);

        string memory imageURI = s_happySvgUri;

        if (s_tokenIdToState[tokenId] == NFTState.SAD) {
            imageURI = s_sadSvgUri;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getHappySVG() public view returns (string memory) {
        return s_happySvgUri;
    }

    function getSadSVG() public view returns (string memory) {
        return s_sadSvgUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
