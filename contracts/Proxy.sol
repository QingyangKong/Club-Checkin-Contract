pragma solidity ^0.4.24;

import "./ClubCheckInControl.sol";
import "./ClubCheckInData.sol";

contract ClubPlayer {
    function getPlayerAddress(address _address) view public returns (address);

    function joinClub(address player, address clubAddress) public;
}

contract Proxy {

    address public clubDataAddress;
    address public clubControlAddress;

    ClubCheckInControl clubControl;
    ClubCheckInData clubData;


    /* 
        There are 3 contracts supposed to be deployed before the contract deployment
        ClubCheckInClubs: records information for all clubs.
        Token: erc20 token contract.
        ClubCheckInPlayers: records information for all players.
    */

    //@param clubsAddress The address of club control contract. Contract ClubCheckInClubs to record all clubs.
    //@param tokenAddress The address of ERC20 token contract.
    //@param playAddress The address of player contract.
    //@param _ClubName The name for club user attempt to create
    //@param _ClubDescribe The description for club user attempts to create
    constructor
        (
        address clubsAddress, 
        address tokenAddress, 
        address playAddress, 
        address logAddress,
        string _ClubName, 
        string _ClubDescribe, 
        uint256 _reportLimit, 
        uint256 _singleBonus, 
        uint256 _punishBonus, 
        uint256 _supportBonus
        )
        public
    {
        require(bytes(_ClubName).length > 0 && bytes(_ClubName).length <= 30);
        require(bytes(_ClubDescribe).length > 0 && bytes(_ClubDescribe).length <= 540);

        //check if sender signed up
        ClubPlayer clubPlayer = ClubPlayer(playAddress);
        require(clubPlayer.getPlayerAddress(msg.sender) == msg.sender);

        //Deploy data contract with token addr.
        //Both of contract address and owner are current msg.sender
        clubDataAddress = new ClubCheckInData(tokenAddress, logAddress);

        //Deploy control contract with club addr, data addr and player addr.
        clubControlAddress = new ClubCheckInControl(clubsAddress, clubDataAddress, playAddress);

        //get instance of data contract
        clubData = ClubCheckInData(clubDataAddress);

        //set data contract's attributes
        clubData.setClubName(_ClubName);
        clubData.setClubDescribe(_ClubDescribe);
        clubData.setReportLimit(_reportLimit);
        clubData.setSingleBonus(_singleBonus);
        clubData.setPunishBonus(_punishBonus);
        clubData.setSupportBonus(_supportBonus);
        clubData.setRound(1);
        clubData.addMember(msg.sender);
        clubData.setOwner(msg.sender);
        clubData.changeAccess(clubControlAddress);

        //set attribute of player contract.
        //admin should join the club.
        clubPlayer.joinClub(msg.sender, clubDataAddress);
    }
}
