// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract FootballOracle {
    // All matches are indexed. Returns whether query was successful, // alongside the scores
    

    //only address who can end matches to the database
    address public owner;

    struct matchResult {
        uint score1;
        uint score2;
        bool exists;
    }

    mapping(uint => matchResult) private matchData;



    constructor()  { 
        
        owner = msg.sender; 
    }


    // send data to contract, can also be used to update records
    function addData(uint32 _matchid, uint _score1, uint _score2) public {

        //only address which created the contract can do this
        require(msg.sender == owner);

        //allow to override old results
        matchResult memory newMatch = matchResult(_score1, _score2, true);


        matchData[_matchid] = newMatch;

    }

    //delete record
    function removeData(uint32 _matchid) public {

        //only address which created the contract can do this
        require(msg.sender == owner);

        delete matchData[_matchid];

    }

    


    //query database

    function getScore(uint matchid) public view returns(bool success, uint score1, uint score2) {

        //check if id in array, if not return false

        if (matchData[matchid].exists) {
            return(true, matchData[matchid].score1, matchData[matchid].score2);
        }

        else {
            return(false, 0, 0);
        }

    }


}
