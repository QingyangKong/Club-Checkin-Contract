pragma solidity ^0.4.24;

import "./ClubCheckInClubs.sol";
// import "./ClubCheckInPlayer.sol";
import "./IClubCheckInLog.sol";

/**
 *  The contract is designed as an entry to all necessary logs used by Re-birth.
 *  The reason we keep a log contract for all logs is because that re-birth cannot dynamically change the contract address.
 **/

contract ClubCheckInLog is IClubCheckInLog {

    //event logs used by clubs
    event RegisterClub(uint256 clubId, address clubAddr);

    //event logs used by users
    event JoinClub(address dataAddr, address userAddr);
    event SignUp(string userName, string iconUrl, address userAddr);
    event ExitClub(address dataAddr, address userAddr);

    //event logs used by clubData
    event SetClubName(address dataAddr, string clubName);
    event SetClubDesc(address dataAddr, string desc);
    event SetClubReportLimit(address dataAddr, uint256 reportLimit);
    event SetRound(address dataAddr, uint256 round);
    event SetOwner(address dataAddr, address adminAddr);
    event ChangeAccess(address dataAddr, address controlAddr);
    event AddMember(address clubAddr, address memberAddress);
    event RemoveMember(address dataAddr, address senderAddr);
    event SupportEvent(address dataAddr, uint256 round, uint256 eventId, address supporterAddr);
    event ReportEvent(address dataAddr, uint256 round, uint256 eventId, address reporterAddr);
    event AddCheckInEvent(string imgUrl, string info, address author, uint256 time, address dataAddr, address controlAddr, uint256 round);
    event SetMemberBonus(address dataAddr, uint256 round, address member, uint256 bonus);

    address public clubsAddr;
    address public usersAddr;
    address public ownerAddr;
    ClubCheckInClubs clubs;

    constructor() public {
        ownerAddr = msg.sender;
    }

    //used to modify clubs and users contract addresses after deployment
    modifier onlyOwner() {
        require(ownerAddr == msg.sender);
        _;
    }

    //only from contract clubs
    modifier fromContractClub() {
        require(clubsAddr == msg.sender);
        _;
    }

    //only from contract users
    modifier fromContractUser() {
        require(usersAddr == msg.sender);
        _;
    }

    //only from one of registered data contract
    modifier fromContractData() {
        require(clubs.clubs(msg.sender));
        _;
    }

    function setUserAndClub(address _clubsAddr, address _usersAddr) 
        public 
        onlyOwner() 
    {
        clubsAddr = _clubsAddr;
        usersAddr = _usersAddr;
        clubs = ClubCheckInClubs(clubsAddr);
    }

    function registerClub(uint256 clubId, address clubAddr) 
        external 
        fromContractClub() 
    {
        emit RegisterClub(clubId, clubAddr);
    }

    function joinClub(address dataAddr, address _userAddr) 
        external 
        fromContractUser()
    {
        emit JoinClub(dataAddr, _userAddr);
    }

    function signUp(string userName, string iconUrl, address userAddr) 
        external 
        fromContractUser()    
    {
        emit SignUp(userName, iconUrl, userAddr);
    }

    function exitClub(address dataAddr, address _userAddr) 
        external 
        fromContractUser()
    {
        emit ExitClub(dataAddr, _userAddr);
    }

    function setClubName(address dataAddr, string clubName) 
        external 
        fromContractData()
    {
        emit SetClubName(dataAddr, clubName);
    }

    function setClubDesc(address dataAddr, string desc) 
        external 
        fromContractData()
    {
        emit SetClubDesc(dataAddr, desc);
    }

    function setClubReportLimit(address dataAddr, uint256 reportLimit) 
        external 
        fromContractData()
    {
        emit SetClubReportLimit(dataAddr, reportLimit);
    }

    function setRound(address dataAddr, uint256 round) 
        external 
        fromContractData()
    {
        emit SetRound(dataAddr, round);
    }

    function setOwner(address dataAddr, address adminAddr) 
        external 
        fromContractData()
    {
        emit SetOwner(dataAddr, adminAddr);
    }

    function changeAccess(address dataAddr, address controlAddr) 
        external 
        fromContractData()
    {
        emit ChangeAccess(dataAddr, controlAddr);
    }

    function addMember(address dataAddr, address memberAddr) 
        external 
        fromContractData()
    {
        emit AddMember(dataAddr, memberAddr);
    }

    function removeMember(address dataAddr, address senderAddr) 
        external 
        fromContractData()
    {
        emit RemoveMember(dataAddr, senderAddr);
    }

    function supportEvent(address dataAddr, uint256 round, uint eventId, address supporterAddr) 
        external 
        fromContractData() 
    {
        emit SupportEvent(dataAddr, round, eventId, supporterAddr);
    }

    function reportEvent(address dataAddr, uint256 round, uint256 eventId, address reporterAddr) 
        external 
        fromContractData() 
    {
        emit ReportEvent(dataAddr, round, eventId, reporterAddr);
    }

    function addCheckInEvent(string imgUrl, string info, address author, uint256 time, address dataAddr, address controlAddr, uint256 round) 
        external 
        fromContractData() 
    {
        emit AddCheckInEvent(imgUrl, info, author, time, dataAddr, controlAddr, round);
    }

    function setMemberBonus(address dataAddr, uint256 round, address member, uint256 bonus) 
        external 
        fromContractData() 
    {
        emit SetMemberBonus(dataAddr, round, member, bonus);
    }
}