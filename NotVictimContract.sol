// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract NotVictimContract {
    
     uint256 public toTransfer = 1 ether;

    //Only 1 ether can be sent by this contract
    //basic in practice would keep track of who deposited what and not waste gas transfering 0 eth
    function withdraw() public payable {

        //balance check
        require(address(this).balance >=1);

        //backup original amount beforr transfer
        uint256 oldToTransfer = toTransfer;
        // Deduct balance by 1mbefore transfer
        toTransfer = 0;
    
        //transfer does not send enough gas to do attack
        payable(msg.sender).transfer(oldToTransfer);
 

    }

    // Use depost() to send 10 ether to contract
    function deposit() public payable {
    }

     function getNotVictimBalance() public view returns(uint) {
        return address(this).balance; 
    }

}   

