// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;


contract DepositAndRefund {

    //Set up a mapping that links an address to a uint.
    mapping(address=> uint) private balance;
    // add timed withdrawals
    mapping(address=> uint) private timer;

    uint256 timeLimit = 1 minutes;

    //get message in bytes, solidity >=8.8
    bytes32 hash_expected_message = getMessageHash("to the moon");


    //Create the function getBalance(address party) to fetch a party’s balance.
    function getBalance(address _party) public view returns (uint){
        return balance[_party];

    }

    //Create the function deposit() to receive and record a party’s deposit. (hint:
    //check the sender and value using msg, and don’t forget the payable keyword).

    function deposit() external payable {
        
        require(msg.value > 0,  "Non positive balance sent"); //wei (ether / 1e18)

        // Update state to deduct the balance of msg.sender 

        balance[msg.sender] = balance[msg.sender]  + msg.value;
        
        //resets with each deposit
        timer[msg.sender] = block.timestamp;

        assert(balance[msg.sender] >= 0); // Check for underflow



    }

    //unites are wei! = ether / 1e18

    function withdraw(uint256 _toWithdraw) external payable { 
        
    //have enough funds to withdrawl
    require(balance[msg.sender] >= _toWithdraw ,  "Not enough balance available to withdrawl" );

    //enough time has passed to withdrawl
    require( block.timestamp - timer[msg.sender]  >=  timeLimit , "Not enough time passed to withdrawl" );
 

    address payable _sender = payable(msg.sender);

     // Update state to deduct the balance of msg.sender // Send coins to msg.sender
    _sender.transfer(_toWithdraw);
     balance[msg.sender] = balance[msg.sender]  - _toWithdraw;

    
    assert(balance[msg.sender] >= 0); // Check for underflow 
    
    }


    function withdraw_signed(uint256 _toWithdraw, bytes calldata _signature) external payable { 
        

    //have enough funds to withdrawl
    require(balance[msg.sender] >= _toWithdraw ,  "Not enough balance available to withdrawl" );

    //enough time has passed to withdrawl - do not use for signed transactions to speedup testing
    //require( block.timestamp - timer[msg.sender]  >=  timeLimit , "Not enough time passed to withdrawl" );
 

    //check signature match
    //use signed hash here as it is different for each account
    address expected_address =  recoverSigner( getEthSignedMessageHash(hash_expected_message), _signature);

    require(expected_address == msg.sender,  "Signature not valid" );


    address payable _sender = payable(msg.sender);

     // Update state to deduct the balance of msg.sender // Send coins to msg.sender
    _sender.transfer(_toWithdraw);
     balance[msg.sender] = balance[msg.sender]  - _toWithdraw;

    
    assert(balance[msg.sender] >= 0); // Check for underflow 
    
    }

    // source for the next helper functions: https://solidity-by-example.org/signature/


    function getMessageHash(string memory item) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(item));
           
            }




    //Signature will be different for different accounts
    //0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    //*/
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }


    function recoverSigner(bytes32 _ethSignedMessageHash, bytes calldata _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }


}
