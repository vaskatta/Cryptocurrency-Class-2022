// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract VictimContract {
    
     uint256 public toTransfer = 1 ether;

    //Only 1 ether can be sent by this contract
    //basic in practice would keep track of who deposited what and not waste gas transfering 0 eth

    function withdraw() public payable {
    
        // Send 1 coin    
        msg.sender.call{value: toTransfer}('');

        //transfer does not send enough gas to do attack
       // payable(msg.sender).transfer(toTransfer);
 

        
        // Deduct balance by 1
        //no matter how much eth has been deposited, contract only allows 1 eth to be withdrawn by anyone
        toTransfer = 0;
    }

    // Use depost() to send 10 ether to contract
    function deposit() public payable {
    }

     function getVictimBalance() public view returns(uint) {
        return address(this).balance; 
    }

}   

