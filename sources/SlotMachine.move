module var::SlotMachine {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;
    
    /// Struct representing the slot machine with progressive jackpot
    struct SlotMachine has store, key {
        jackpot_pool: u64,        // Progressive jackpot amount
        house_balance: u64,       // House earnings
        bet_amount: u64,          // Fixed bet amount per spin
        total_spins: u64,         // Total number of spins
        machine_funds: u64,       // Available funds for payouts
    }
    
    /// Initialize the slot machine with bet amount
    public fun initialize_slot_machine(owner: &signer, bet_amount: u64) {
        let slot_machine = SlotMachine {
            jackpot_pool: 0,
            house_balance: 0,
            bet_amount,
            total_spins: 0,
            machine_funds: 0,
        };
        move_to(owner, slot_machine);
    }
    
    /// Main function to spin the slot machine
    public fun spin_slot_machine(
        player: &signer, 
        machine_owner: address
    ) acquires SlotMachine {
        let machine = borrow_global_mut<SlotMachine>(machine_owner);
        
        // Collect bet from player
        let bet = coin::withdraw<AptosCoin>(player, machine.bet_amount);
        let bet_amount = coin::value(&bet);
        
        // Add bet to machine funds
        machine.machine_funds = machine.machine_funds + bet_amount;
        coin::deposit<AptosCoin>(machine_owner, bet);
        
        // Generate three random numbers (0-9) using simple pseudo-random
        let seed = machine.total_spins;
        let num1 = ((seed * 7 + 13) % 10 as u8);
        let num2 = ((seed * 11 + 17) % 10 as u8);
        let num3 = ((seed * 19 + 23) % 10 as u8);
        
        machine.total_spins = machine.total_spins + 1;
        
        // Add 10% of bet to jackpot pool
        machine.jackpot_pool = machine.jackpot_pool + (bet_amount / 10);
        // Add 40% to house balance
        machine.house_balance = machine.house_balance + (bet_amount * 4 / 10);
        
        // Calculate winnings
        let (win_amount, is_jackpot) = calculate_winnings(num1, num2, num3, machine);
        
        // Track winnings but don't pay out automatically
        if (win_amount > 0 && machine.machine_funds >= win_amount) {
            machine.machine_funds = machine.machine_funds - win_amount;
            
            if (is_jackpot) {
                machine.jackpot_pool = 0;
            };
        };
    }
    
    /// Calculate winnings based on slot results
    fun calculate_winnings(num1: u8, num2: u8, num3: u8, machine: &SlotMachine): (u64, bool) {
        // Jackpot: All three 7s
        if (num1 == 7 && num2 == 7 && num3 == 7) {
            return (machine.jackpot_pool, true)
        };
        
        // Three of a kind (except 7s): 10x bet
        if (num1 == num2 && num2 == num3 && num1 != 7) {
            return (machine.bet_amount * 10, false)
        };
        
        // Two of a kind: 2x bet
        if (num1 == num2 || num2 == num3 || num1 == num3) {
            return (machine.bet_amount * 2, false)
        };
        
        // No win
        (0, false)
    }
}