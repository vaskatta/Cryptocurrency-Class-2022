// SPDX-License-Identifier: GPL-3.0



//using advice from https://eprint.iacr.org/2015/460.pdf
//and sample code here https://github.com/mc2-umd/ethereumlab/blob/master/Examples/RPS_v2_new.py

pragma solidity >=0.8.7 <0.9.0;

contract RockPaperScissors {

    //set up player object
    struct PlayerData {
        address p_address;
        bytes32  commit;
        uint8 choice;
        bool has_revealed;

    }

    //add variables to use
    mapping(uint => PlayerData) private player;

    mapping(string => uint8) private choice_n;
  
    uint8[3][3] check_winner;
    uint256 num_players;

    uint256 reward;
    uint256 target_committment;
    bool timer_start;
    uint256 timer_block;
    uint8 block_limit;


    //initialise contract; fill in win conditions
    //add amount to commit to bet
    // add number of blocks to wait for reveal after first reveal;
    
    constructor(uint256 _target_committment, uint8 _block_limit)  { 

        //player 0 wins -> 0; player 1 wins -> 1; 2 if tie;

        //choices 0 = rock; 1 = paper; 2 = scissors;
          
        choice_n["rock"] = 0;
        choice_n["paper"] = 1;
        choice_n["scissors"] = 2;



        // ties
        check_winner[0][0] = 2;
        check_winner[1][1] = 2;
        check_winner[2][2] = 2;

        // rock > scissors
        check_winner[0][2] = 0;
        check_winner[2][0] = 1;

        //scissors > paper
        check_winner[2][1] = 0;
        check_winner[1][2] = 1;

        //paper > rock
        check_winner[1][0] = 0;
        check_winner[0][1] = 1;

        //initiate empty player count
	    num_players = 0;

        reward = 0;
        target_committment = _target_committment;
        block_limit = _block_limit;

    }

    // accept hashed player committment
    // generate message hash from getMessageHash function
    // sign hashed output using getEthSignedMessageHash function
    //send output as playyer msg_committment
    function add_player(bytes32 msg_committment) public payable returns (uint8) {

        //prevent max callstack exception
        if (test_callstack() != 1)  {
            return 2;
        }

        //still space for players; committment meets min threshold value;
        if ((num_players < 2) && (msg.value >= target_committment)) {
            
            //increase reward pot
            reward +=  msg.value;
            
            //add player
            PlayerData memory _new_player = PlayerData(msg.sender, msg_committment,10,false);
  
            player[num_players ] = _new_player;
        

            //increment number of players
            num_players += 1;

            return 0;

        } 
        //if committment too low; sorry still keeping it ; 
        //can't waste gas fees to return it;
        else if (msg.value > 0 ) {
            reward +=  msg.value;
            return 3;
        }
    }


    //open committment for  player
    function reveal_choice(string calldata choice) public returns (uint)  {


        //prevent max callstack exception
        if (test_callstack() != 1)  {
            return 2;
        }

        //check that two players have submitted choices
        if (num_players != 2) {
            return 3;
        }

        //assign player number
        uint8 _n_player;

        if (msg.sender == player[0].p_address) {
            _n_player = 0;
        }

        else if (msg.sender == player[1].p_address) {
            _n_player = 1;
        }

        else {
            return 4;
        }

        //confirm choice is the committed one (only perform if choice not yet revealed)
        if ((! player[_n_player].has_revealed) && (getEthSignedMessageHash(getMessageHash(choice)) == player[_n_player].commit)) {
            //if match/verified, add to struct
            //add choice as number
            player[_n_player].choice = choice_n[choice];
            //if choice not in mapping, it should fail
            //update revealed'
            player[_n_player].has_revealed = true;
            //start timer
            if (! timer_start) {
                timer_block = block.number;
                return 0;
            }
            return 0;
        } else {
            return 5;
        }

    }

    function reveal_winner() public payable returns (uint) {

        //prevent max callstack exception
        if (test_callstack() != 1)  {
            return 2;
        }

        // if both players have revealed cmmittment determine winner;
        if ((player[0].has_revealed) && (player[0].has_revealed)) {
            uint8 c0 = player[0].choice;
            uint8 c1 = player[1].choice;

            //transfer does not send enough gas to do attack contract; relevant when tie;

            //if p1 wins
            if (check_winner[c0][c1] == 0 ) {
                address payable _winner = payable(player[0].p_address);
                _winner.transfer(reward);
			    return 0;
            }
            //if p2 wins
            else if  (check_winner[c0][c1] == 1 ) {

                address payable _winner = payable(player[1].p_address);
                _winner.transfer(reward);
			    return 1;
            }
            
            //check what happens if invalid choice;
            else {
                payable(player[0].p_address).transfer(reward / 2);
                payable(player[1].p_address).transfer(reward / 2);
                return 3;
            }
        }
        //if one hasnt revealed check if block time still leaves option to reveal;
        if (block.number - timer_block < block_limit) {
            return 4;    
        }

        if ((player[0].has_revealed) && (! player[1].has_revealed)) {
            payable(player[0].p_address).transfer(reward);
		    return 5;
        } 
        else if ((player[1].has_revealed) && (! player[0].has_revealed)) {
            payable(player[1].p_address).transfer(reward);
		    return 6;
        }
        //neither revealed - keep money for now
        else {
            return 7;
        }

    }

    //helper functions

      
   //check minimum amount to commit to bet
    function  check_committment_size()  public view returns (uint256) {
        return target_committment;
    }

    //check if callstack is full?
    function test_callstack() public  pure  returns (uint256 ) {
        return 1;
    }

    //
     function getPlayerObject(uint _n_player) public view returns (PlayerData memory) {
        return player[_n_player];
    }


    // check mapping of choices from string to int
    //only returns if in mapping
    function getChoiceMap(string calldata str) public view returns (uint8) {
        return choice_n[str];
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

    //helper function from https://gist.github.com/ageyev/779797061490f5be64fb02e978feb6ac

    function stringToBytes32(string memory source) public  pure returns (bytes32 result) {
        // require(bytes(source).length <= 32); // causes error
        // but string have to be max 32 chars
        // https://ethereum.stackexchange.com/questions/9603/understanding-mload-assembly-function
        // http://solidity.readthedocs.io/en/latest/assembly.html
        assembly {
        result := mload(add(source, 32))
        }

        return result;
    }

}
