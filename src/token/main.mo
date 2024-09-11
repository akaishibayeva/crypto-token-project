import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";

actor Token {

    Debug.print("Hello!");

// converst to Principal data type
    let owner : Principal = Principal.fromText("ufz7v-7iu2v-y66ba-m3oz7-unu5k-qljq7-vvujy-xah6k-jfjkq-jlyf3-nae");

    //total supply of a token
    let totalSupply : Nat = 1000000000;

    let symbol : Text = "DAIN";

    //create temp variable Array of a stable type
    private stable var balanceEntries: [(Principal, Nat)] = [];

    //keeps track of who owns how much tokens
    private var balances  = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
    if (balances.size() < 1) { //checks if ledger is empty. If it is, put token supply
            balances.put(owner, totalSupply); //ledger balances
        };

    //check balance: takes an id and returns natural nuber
    public query func balanceOf(who : Principal) : async Nat {

        let balance : Nat = switch (balances.get(who)) {
            case null 0;
            case (?result) result;
        };
        return balance;
        
    };

    public query func getSymbol() : async Text {
        return symbol;
    };

    public shared(msg) func payOut() : async Text {

        //if caller never requested tokens, we transfer
        if (balances.get(msg.caller) == null) {
            Debug.print(debug_show(msg.caller));
            let amount = 10000;
            let result = await transfer(msg.caller, amount);
            return result;
        } else {
            "Already Claimed Your Tokens!";
        }
        
    };

    public shared(msg) func transfer(to: Principal, amount: Nat) : async Text {
        let balanceFrom = await balanceOf(msg.caller);

        if(balanceFrom > amount) {
            let newFromBalance : Nat = balanceFrom - amount; //subtracted from the balance of the sender
            balances.put(msg.caller, newFromBalance);

            let toBalance = await balanceOf(to);
            let newToBalance = toBalance + amount; //added to a balance of recepient
            balances.put(to, newToBalance); //updated ledger

            return "Success!";
        } else {
            return "Insufficient Funds!";
        }
        
    };

    system func preupgrade() {
        balanceEntries:= Iter.toArray(balances.entries()); //take balances HashMap and entries() iterate through each items

    };

//after upgrade shift back to HashMap
    system func postupgrade() {
        balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        if (balances.size() < 1) { //checks if ledger is empty. If it is, put token supply
            balances.put(owner, totalSupply); //ledger balances
        }
        
    };
 };