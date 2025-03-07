// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RockPaperScissors {
    enum Move { None, Rock, Paper, Scissors }

        struct Player {
            address payable addr;
            bytes32 moveHash;
            Move move;
            bool revealed;
        }

        Player[2] public players;
    uint256 public betAmount;
    uint8 public playerCount;
    bool public gameFinished;

    event PlayerJoined(address player);
    event GameRevealed(address player, Move move);
    event GameFinished(address winner, uint256 amount);
    event GameDraw();

    modifier onlyPlayers() {
        require(msg.sender == players[0].addr || msg.sender == players[1].addr, "Not a participant");
        _;
    }

    function joinGame(bytes32 moveHash) external payable {
        require(playerCount < 2, "Game is full");
        require(msg.value > 0, "Must send ETH to bet");

        if (playerCount == 0) {
            betAmount = msg.value;
        } else {
            require(msg.value == betAmount, "Bet amount must be the same");
        }

        players[playerCount] = Player(payable(msg.sender), moveHash, Move.None, false);
        playerCount++;
        emit PlayerJoined(msg.sender);
    }

    function revealMove(Move move, string memory secret) external onlyPlayers {
        require(playerCount == 2, "Waiting for players");
        uint8 playerIndex = (msg.sender == players[0].addr) ? 0 : 1;
        require(players[playerIndex].revealed == false, "Already revealed");
        require(keccak256(abi.encodePacked(move, secret)) == players[playerIndex].moveHash, "Invalid move or secret");

        players[playerIndex].move = move;
        players[playerIndex].revealed = true;

        emit GameRevealed(msg.sender, move);

        if (players[0].revealed && players[1].revealed) {
            _determineWinner();
        }
    }

    function _determineWinner() internal {
        Move move1 = players[0].move;
        Move move2 = players[1].move;
        address payable winner;

        if (move1 == move2) {
            emit GameDraw();
            players[0].addr.transfer(betAmount);
            players[1].addr.transfer(betAmount);
        } else if (
                   (move1 == Move.Rock && move2 == Move.Scissors) ||
                   (move1 == Move.Paper && move2 == Move.Rock) ||
                   (move1 == Move.Scissors && move2 == Move.Paper)
        ) {
            winner = players[0].addr;
        } else {
            winner = players[1].addr;
        }

        if (winner != address(0)) {
            emit GameFinished(winner, betAmount * 2);
            winner.transfer(betAmount * 2);
        }

        gameFinished = true;
    }
}
