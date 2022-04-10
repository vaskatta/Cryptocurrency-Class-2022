// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;


abstract contract  FootballOracle   {
 //All matches are indexed. Returns whether query was successful, // alongside the scores
    function getScore(uint matchid) public virtual returns(bool success, uint score1, uint score2);
}

contract EmitMatchEvent {

    event MatchScore(uint matchid, uint score1, uint score2); 
    FootballOracle public oracle;

    constructor(address _oracle) { 
        
        oracle = FootballOracle( _oracle); 
    }

    function checkScore(uint matchid) public {
        
        bool success; 
        uint score1; 
        uint score2;
        // Fetch scores from the oracle
        (success, score1, score2) = oracle.getScore( matchid);
        // If query works, tell world about the score!
        if(success) {
        emit MatchScore( matchid, score1, score2);
        } 
    }
}
