// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title HelloWorld
 * @dev Implements a hellow world message emitter 
 */
contract HelloWorld {


    string[] public message;
    address latest_user;

    //Admin
    address public owner;

    //string[] public list_messages; // Dynamic size array
    // Do not use in practice, dangerous
    //record which message was sent by whom
    mapping(address=> string[]) public address_messages;

    mapping(address=> bool) public MIsAllowed;

    /**
    
    emit event hello

    **/

    constructor () {
        //contract ownerd by its creator
        owner = msg.sender;
    }

    event NewMessage(string _msg);


    modifier IsOwner() {
        require(msg.sender == owner, "Only Admin can update");
        _;

    }

    modifier IsAllowed() {
        require(MIsAllowed[msg.sender], "Only Special USsrs can update");
        _;

    }


    function emitHello() public  {
    
        emit NewMessage(message[message.length-1]);
    }

    function addSpecialUser(address _specialUser) public IsOwner() {
        MIsAllowed[_specialUser] = true;
    }
  
    function  updateMessage(string calldata _msg) public IsAllowed() {

        // require(msg.sender == owner, "Only Admin can update");

        message.push(_msg);
        emit NewMessage(_msg);
        
        //update message
       // message = _msg;
       
        //update latest user
       latest_user = msg.sender;

        //save message to list of messages
        //list_messages.push(msg1);
        address_messages[msg.sender].push(_msg);

    }

    function getMessage(address user, uint i) public view returns(string memory) {
        return address_messages[user][i];
    }


    function latestMessage() public view returns(address, string memory) {
        return (latest_user, message[message.length-1]); 
    }

}

    /** 
     * @dev when called returns a string "hello"
     * @return "hello"
     */
    //function hello() public pure returns (string memory) {
   //         return "hello";
    //    }
   // }
