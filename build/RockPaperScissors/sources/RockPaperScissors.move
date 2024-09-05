address 0xde2f1d2d656f76609fb7a9db175e47f6c59cf81cd42a420a57ddad28a4ab3f21 {

module RockPaperScissors {
    use std::signer;
    use aptos_framework::randomness;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    struct Game has key {
        player1: address,
        player2: address,
        player1_move: u8,
        player2_move: u8,
        computer_move: u8,
        result: u8,
        player1_wins: u64,
        player2_wins: u64,
        computer_wins: u64,
    }

    // Starts a new game if none exists
    public entry fun start_game(account: &signer, opponent: address) {
        let player1 = signer::address_of(account);

        if (!exists<Game>(player1)) {
            let game = Game {
                player1,
                player2: opponent,
                player1_move: 0,
                player2_move: 0,
                computer_move: 0,
                result: 0,
                player1_wins: 0,
                player2_wins: 0,
                computer_wins: 0,
            };
            move_to(account, game);
        }
    }

    // Sets the move for player 1
    public entry fun set_player1_move(account: &signer, player1_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player1_move = player1_move;
    }

    // Sets the move for player 2
    public entry fun set_player2_move(account: &signer, player2_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player2_move = player2_move;
        game.computer_move = 0;
    }

    // Randomly sets the computer's move
    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires Game {
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        let random_number = randomness::u8_range(1, 4);
        game.computer_move = random_number;
    }
    
    // Finalize game and determine the winner
    public entry fun finalize_game_results(account: &signer) acquires Game {
    let game = borrow_global_mut<Game>(signer::address_of(account));
    if (game.computer_move == 0) {
        game.result = determine_winner(game.player1_move, game.player2_move);
    } else {
        game.result = determine_winner(game.player1_move, game.computer_move);
    }
}
    // Increment win counts based on the result
    public entry fun update_win_counts(account: &signer) acquires Game {
    let game = borrow_global_mut<Game>(signer::address_of(account));
    if (game.result == 2) {
        game.player1_wins = game.player1_wins + 1;
    } else if (game.result == 3) {
        if (game.computer_move == 0) {
            game.player2_wins = game.player2_wins + 1;
        } else {
            game.computer_wins = game.computer_wins + 1;
        }
    };
}

    // Reset all stored wins (players wins and computer wins)
    public entry fun clear_all_wins(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player1_wins = 0;
        game.player2_wins = 0;
        game.computer_wins = 0;
    }

    fun determine_winner(player1_move: u8, player2_move: u8): u8 {
        if (player1_move == ROCK && player2_move == SCISSORS) {
            2 // player1 wins
        } else if (player1_move == PAPER && player2_move == ROCK) {
            2 // player1 wins
        } else if (player1_move == SCISSORS && player2_move == PAPER) {
            2 // player1 wins
        } else if (player1_move == player2_move) {
            1 // draw
        } else {
            3 // player2 wins
        }
    }

    #[view]
    public fun get_game_results(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).result
    }
    
    #[view]
    public fun get_player1_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player1_move
    }

    #[view]
    public fun get_player2_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player2_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_move
    }

    #[view]
    public fun get_player1_wins(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).player1_wins
    }

    #[view]
    public fun get_player2_wins(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).player2_wins
    }

    #[view]
    public fun get_computer_wins(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).computer_wins
    }
}
}
