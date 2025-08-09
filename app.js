
import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";

class SlotMachineApp {
    constructor() {
        this.aptos = new Aptos(new AptosConfig({ network: Network.TESTNET }));
        this.wallet = null;
        this.userAddress = "";
        this.contractAddress = "8717ea23e50c23a9eacf97946663825ceaeafabba45f9c025cdf4f9e0766a5e0"; 
    }

    async connectWallet() {
        try {
            if (!window.aptos) {
                alert("Please install Petra Wallet");
                return;
            }

            const response = await window.aptos.connect();
            this.userAddress = response.address;
            this.wallet = window.aptos;
            
            console.log("Connected to wallet:", this.userAddress);
            this.updateUI();
            
        } catch (error) {
            console.error("Failed to connect wallet:", error);
        }
    }

    async initializeSlotMachine() {
        try {
            const transaction = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::SlotMachine::initialize_slot_machine`,
                arguments: [100000000], 
                type_arguments: []
            };

            const response = await this.wallet.signAndSubmitTransaction(transaction);
            await this.aptos.waitForTransaction({ transactionHash: response.hash });
            
            console.log("Slot machine initialized:", response.hash);
            
        } catch (error) {
            console.error("Failed to initialize:", error);
        }
    }

    async spinSlotMachine() {
        try {
            const transaction = {
                type: "entry_function_payload",
                function: `${this.contractAddress}::SlotMachine::spin_slot_machine`,
                arguments: [this.contractAddress],
                type_arguments: []
            };

            const response = await this.wallet.signAndSubmitTransaction(transaction);
            await this.aptos.waitForTransaction({ transactionHash: response.hash });
            
            console.log("Spin completed:", response.hash);
            
        } catch (error) {
            console.error("Failed to spin:", error);
        }
    }

    updateUI() {
    
        document.getElementById('connectBtn').textContent = 'Connected ✓';
        document.getElementById('connectBtn').disabled = true;
        document.getElementById('initBtn').disabled = false;
    }
}

// Initialize app
const app = new SlotMachineApp();

window.app = app;
