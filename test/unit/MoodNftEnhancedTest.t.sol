// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {MoodNft} from "../../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoodNftEnhancedTest is Test {
    MoodNft moodNft;
    string public constant HAPPY_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==";
    string public constant SAD_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgaGVpZ2h0PSI0MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiBmaWxsPSIjQUREOEU2IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtNTUgMTM1YzE3LjUtNDIgODItMjYgODEuNS0wLjciIHN0eWxlPSJmaWxsOm5vbmU7IHN0cm9rZTogYmxhY2s7IHN0cm9rZS13aWR0aDogMzsiLz4KPC9zdmc+";

    address USER = makeAddr("user");
    address OWNER = makeAddr("owner");
    address APPROVED = makeAddr("approved");

    event CreatedNFT(uint256 indexed tokenId);

    function setUp() public {
        vm.prank(OWNER);
        moodNft = new MoodNft(SAD_SVG_URI, HAPPY_SVG_URI);
    }

    function testInitializedCorrectly() public view {
        assertEq(moodNft.name(), "Mood NFT");
        assertEq(moodNft.symbol(), "MN");
        assertEq(moodNft.getTokenCounter(), 0);
    }

    function testMintNftSuccess() public {
        vm.prank(USER);
        moodNft.mintNft();

        assertEq(moodNft.balanceOf(USER), 1);
        assertEq(moodNft.ownerOf(0), USER);
        assertEq(moodNft.getTokenCounter(), 1);
    }

    function testMintEmitsEvent() public {
        vm.prank(USER);
        vm.expectEmit(true, false, false, false);
        emit CreatedNFT(0);
        moodNft.mintNft();
    }

    function testOwnerCanFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        string memory initialUri = moodNft.tokenURI(0);

        vm.prank(USER);
        moodNft.flipMood(0);

        string memory flippedUri = moodNft.tokenURI(0);

        assertTrue(
            keccak256(abi.encodePacked(initialUri)) !=
                keccak256(abi.encodePacked(flippedUri)),
            "URI should change after flip"
        );
    }

    function testApprovedCanFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        vm.prank(USER);
        moodNft.approve(APPROVED, 0);

        vm.prank(APPROVED);
        moodNft.flipMood(0);
    }

    function testUnauthorizedCannotFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        address unauthorized = makeAddr("unauthorized");

        vm.prank(unauthorized);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
    }

    function testApprovedForAllCanFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();

        address operator = makeAddr("operator");

        // Use setApprovalForAll to approve operator for all tokens
        vm.prank(USER);
        moodNft.setApprovalForAll(operator, true);

        // Operator should be able to flip mood
        vm.prank(operator);
        moodNft.flipMood(0);
    }

    function testTokenURIForNonExistentToken() public {
        vm.expectRevert(); // Just expect any revert since OpenZeppelin changed error types
        moodNft.tokenURI(999);
    }

    function testFlipMoodToggles() public {
        vm.prank(USER);
        moodNft.mintNft();

        string memory original = moodNft.tokenURI(0);

        // First flip
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory flipped = moodNft.tokenURI(0);

        // Second flip - should return to original
        vm.prank(USER);
        moodNft.flipMood(0);
        string memory backToOriginal = moodNft.tokenURI(0);

        assertEq(
            keccak256(abi.encodePacked(original)),
            keccak256(abi.encodePacked(backToOriginal))
        );

        assertTrue(
            keccak256(abi.encodePacked(original)) !=
                keccak256(abi.encodePacked(flipped))
        );
    }

    function testGetterFunctions() public view {
        assertEq(moodNft.getHappySVG(), HAPPY_SVG_URI);
        assertEq(moodNft.getSadSVG(), SAD_SVG_URI);
        assertEq(moodNft.owner(), OWNER);
    }

    function testMultipleNFTs() public {
        // Mint two NFTs
        vm.prank(USER);
        moodNft.mintNft();

        address user2 = makeAddr("user2");
        vm.prank(user2);
        moodNft.mintNft();

        assertEq(moodNft.getTokenCounter(), 2);
        assertEq(moodNft.ownerOf(0), USER);
        assertEq(moodNft.ownerOf(1), user2);

        // Flip only first NFT
        vm.prank(USER);
        moodNft.flipMood(0);

        // URIs should be different now
        string memory uri0 = moodNft.tokenURI(0);
        string memory uri1 = moodNft.tokenURI(1);

        assertTrue(
            keccak256(abi.encodePacked(uri0)) !=
                keccak256(abi.encodePacked(uri1)),
            "Different NFTs should have different moods"
        );
    }
}
