// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/RockPaperScissors.sol";

contract RockPaperScissorsTest is Test {
    RockPaperScissors game;
    address player1 = address(0x1);
    address player2 = address(0x2);
    string secret1 = "secret123";
    string secret2 = "secret456";

    function setUp() public {
        game = new RockPaperScissors();
    }

    function testGameFlow() public {
        bytes32 moveHash1 = keccak256(abi.encodePacked(uint8(1), secret1)); // Rock
        bytes32 moveHash2 = keccak256(abi.encodePacked(uint8(2), secret2)); // Paper

        vm.deal(player1, 10 ether);
        vm.deal(player2, 10 ether);

        vm.prank(player1);
        game.joinGame{value: 1 ether}(moveHash1);

        vm.prank(player2);
        game.joinGame{value: 1 ether}(moveHash2);

        vm.prank(player1);
        game.revealMove(RockPaperScissors.Move.Rock, secret1);

        vm.prank(player2);
        game.revealMove(RockPaperScissors.Move.Paper, secret2);

        assertEq(game.gameFinished(), true);
    }
}
