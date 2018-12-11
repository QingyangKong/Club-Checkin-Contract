pragma solidity ^0.4.24;

interface IClubCheckInLog {
    
    function registerClub(uint256 clubId, address clubAddr) external;

    function joinClub(address dataAddr, address _userAddr) external;

    function signUp(string userName, string iconUrl, address userAddr) external;

    function exitClub(address dataAddr, address _userAddr) external;

    function setClubName(address dataAddr, string clubName) external;

    function setClubDesc(address dataAddr, string desc) external;

    function setClubReportLimit(address dataAddr, uint256 reportLimit) external;

    function setRound(address dataAddr, uint256 round) external;

    function setOwner(address dataAddr, address adminAddr) external;

    function changeAccess(address dataAddr, address controlAddr) external;

    function addMember(address dataAddr, address memberAddr) external;

    function removeMember(address dataAddr, address senderAddr) external;

    function supportEvent(address dataAddr, uint256 round, uint eventId, address supporterAddr) external;

    function reportEvent(address dataAddr, uint256 round, uint256 eventId, address reporterAddr) external;

    function addCheckInEvent(
        string imgUrl, string info, address author, uint256 time, address dataAddr, address controlAddr, uint256 round) external;

    function setMemberBonus(address dataAddr, uint256 round, address member, uint256 bonus) external;
}