// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {MoodNft} from "../../src/MoodNft.sol";
import {Test, console} from "forge-std/Test.sol";

contract MoodNftAdvancedTest is Test {
    MoodNft moodNft;
    string public constant HAPPY_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtMTM2LjgxIDExNi1M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==";
    string public constant SAD_SVG_URI =
        "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgaGVpZ2h0PSI0MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiBmaWxsPSIjQUREOEU2IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNzAiIGN5PSI4MiIgcj0iMTIiLz4KICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJtNTUgMTM1YzE3LjUtNDIgODItMjYgODEuNS0wLjciIHN0eWxlPSJmaWxsOm5vbmU7IHN0cm9rZTogYmxhY2s7IHN0cm9rZS13aWR0aDogMzsiLz4KPC9zdmc+";

    address OWNER = makeAddr("owner");
    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");
    address OPERATOR = makeAddr("operator");

    function setUp() public {
        vm.prank(OWNER);
        moodNft = new MoodNft(SAD_SVG_URI, HAPPY_SVG_URI);
    }

    // =================== Gas Optimization Tests ===================
    function testMintingGasUsage() public {
        vm.prank(USER1);
        uint256 gasBefore = gasleft();
        moodNft.mintNft();
        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas used for minting:", gasUsed);

        // Reasonable gas usage for minting (adjust based on your needs)
        assertTrue(gasUsed < 200000, "Minting uses too much gas");
    }

    function testFlipMoodGasUsage() public {
        vm.prank(USER1);
        moodNft.mintNft();

        vm.prank(USER1);
        uint256 gasBefore = gasleft();
        moodNft.flipMood(0);
        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas used for mood flip:", gasUsed);

        // Reasonable gas usage for mood flip
        assertTrue(gasUsed < 100000, "Mood flip uses too much gas");
    }

    // =================== Complex Authorization Tests ===================
    function testApprovedOperatorCanFlipMood() public {
        // Mint NFT
        vm.prank(USER1);
        moodNft.mintNft();

        // Approve specific token to operator (not setApprovalForAll)
        vm.prank(USER1);
        moodNft.approve(OPERATOR, 0);

        // Operator should be able to flip mood
        vm.prank(OPERATOR);
        moodNft.flipMood(0);

        // Should succeed without reverting
    }

    function testRevokedApprovalCannotFlipMood() public {
        // Mint NFT
        vm.prank(USER1);
        moodNft.mintNft();

        // Approve operator
        vm.prank(USER1);
        moodNft.approve(OPERATOR, 0);

        // Revoke approval
        vm.prank(USER1);
        moodNft.approve(address(0), 0);

        // Operator should no longer be able to flip mood
        vm.prank(OPERATOR);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
    }

    // =================== Batch Operations Tests ===================
    function testMultipleMoodsIndependent() public {
        // Mint multiple NFTs
        vm.prank(USER1);
        moodNft.mintNft(); // Token ID 0

        vm.prank(USER2);
        moodNft.mintNft(); // Token ID 1

        // Get initial URIs
        string memory token0InitialUri = moodNft.tokenURI(0);
        string memory token1InitialUri = moodNft.tokenURI(1);

        // Both should be happy initially (same URI)
        assertEq(
            keccak256(abi.encodePacked(token0InitialUri)),
            keccak256(abi.encodePacked(token1InitialUri))
        );

        // Flip only token 0
        vm.prank(USER1);
        moodNft.flipMood(0);

        string memory token0FlippedUri = moodNft.tokenURI(0);
        string memory token1UnchangedUri = moodNft.tokenURI(1);

        // Token 0 should be different now
        assertNotEq(
            keccak256(abi.encodePacked(token0FlippedUri)),
            keccak256(abi.encodePacked(token0InitialUri))
        );

        // Token 1 should remain unchanged
        assertEq(
            keccak256(abi.encodePacked(token1UnchangedUri)),
            keccak256(abi.encodePacked(token1InitialUri))
        );
    }

    // =================== Edge Case Tests ===================
    function testTokenURIAfterTransfer() public {
        // Mint NFT
        vm.prank(USER1);
        moodNft.mintNft();

        string memory initialUri = moodNft.tokenURI(0);

        // Transfer to USER2
        vm.prank(USER1);
        moodNft.transferFrom(USER1, USER2, 0);

        // URI should remain the same after transfer
        string memory uriAfterTransfer = moodNft.tokenURI(0);
        assertEq(
            keccak256(abi.encodePacked(initialUri)),
            keccak256(abi.encodePacked(uriAfterTransfer))
        );

        // New owner should be able to flip mood
        vm.prank(USER2);
        moodNft.flipMood(0);

        // Old owner should not be able to flip mood
        vm.prank(USER1);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
    }

    function testConsistentTokenURIFormat() public {
        vm.prank(USER1);
        moodNft.mintNft();

        string memory happyUri = moodNft.tokenURI(0);

        vm.prank(USER1);
        moodNft.flipMood(0);

        string memory sadUri = moodNft.tokenURI(0);

        // Both URIs should have the correct base64 prefix
        string memory expectedPrefix = "data:application/json;base64,";
        assertTrue(
            _startsWith(happyUri, expectedPrefix),
            "Happy URI missing correct prefix"
        );
        assertTrue(
            _startsWith(sadUri, expectedPrefix),
            "Sad URI missing correct prefix"
        );

        // Both should be valid base64 (no obvious invalid characters)
        assertTrue(
            _isValidBase64Format(happyUri),
            "Happy URI not valid base64 format"
        );
        assertTrue(
            _isValidBase64Format(sadUri),
            "Sad URI not valid base64 format"
        );
    }

    // =================== Stress Tests ===================
    function testMintManyNFTs() public {
        uint256 numToMint = 10;

        for (uint256 i = 0; i < numToMint; i++) {
            address user = address(uint160(i + 1000)); // Create unique addresses
            vm.prank(user);
            moodNft.mintNft();

            assertEq(moodNft.ownerOf(i), user);
        }

        assertEq(moodNft.getTokenCounter(), numToMint);
    }

    function testFlipMoodMultipleTimes() public {
        vm.prank(USER1);
        moodNft.mintNft();

        string memory originalUri = moodNft.tokenURI(0);

        // Flip 10 times
        for (uint256 i = 0; i < 10; i++) {
            vm.prank(USER1);
            moodNft.flipMood(0);
        }

        string memory finalUri = moodNft.tokenURI(0);

        // After even number of flips, should be back to original
        assertEq(
            keccak256(abi.encodePacked(originalUri)),
            keccak256(abi.encodePacked(finalUri))
        );
    }

    // =================== Ownership Tests ===================
    function testOwnershipFunctions() public {
        assertEq(moodNft.owner(), OWNER);

        // Transfer ownership
        vm.prank(OWNER);
        moodNft.transferOwnership(USER1);

        assertEq(moodNft.owner(), USER1);
    }

    // =================== Helper Functions ===================
    function _startsWith(
        string memory str,
        string memory prefix
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);

        if (strBytes.length < prefixBytes.length) {
            return false;
        }

        for (uint i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) {
                return false;
            }
        }

        return true;
    }

    function _isValidBase64Format(
        string memory str
    ) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);

        // Skip the prefix
        string memory prefix = "data:application/json;base64,";
        uint256 prefixLength = bytes(prefix).length;

        if (strBytes.length <= prefixLength) {
            return false;
        }

        // Check that remaining characters are valid base64
        for (uint256 i = prefixLength; i < strBytes.length; i++) {
            bytes1 char = strBytes[i];
            bool isValid = (char >= "A" && char <= "Z") ||
                (char >= "a" && char <= "z") ||
                (char >= "0" && char <= "9") ||
                char == "+" ||
                char == "/" ||
                char == "=";

            if (!isValid) {
                return false;
            }
        }

        return true;
    }
}
