pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./ClubCheckInData.sol";

contract Erc20 {
    function transfer(address _to, uint256 _value) public returns (bool success);

    function balanceOf(address _owner) public returns (uint256 balance);
}

contract ClubCPlayer {

    function checkIfRegistered(address _address) view public returns (bool);

    function getPlayerAddress(address _address) view public returns (address);

    function joinClub(address player, address clubAddress) public;
}

contract Clubs {
    function add(address _club) public;
}

contract ClubCheckInControl {

    ClubCheckInData ClubData;
    ClubCPlayer ClubPlayer;
    Clubs clubs;

    address public myDataAddress;

    constructor 
        (address clubsAddress, address dataAddress, address playAddress)
        public
    {
        myDataAddress = dataAddress;

        ClubPlayer = ClubCPlayer(playAddress);

        clubs = Clubs(clubsAddress);
        clubs.add(dataAddress);

        ClubData = ClubCheckInData(dataAddress);
    }

    modifier onlyOwner() {
        require(ClubData.owner() == msg.sender);
        _;
    }

    modifier isSignUp() {
        require(ClubData.signUps(msg.sender));
        _;
    }

    modifier checkinEventExist(uint256 _round, uint256 id) {
        require(ClubData.getEventId(_round, id) == id);
        _;
    }

    function setOwner(address _address)
        public
        onlyOwner()
    {
        ClubData.setOwner(_address);
    }

    function setClubName(string name)
        public
        onlyOwner()
    {
        require(bytes(name).length > 0 && bytes(name).length <= 30);
        ClubData.setClubName(name);
    }

    function setClubDescribe(string desc)
        public
        onlyOwner()
    {
        require(bytes(desc).length > 0 && bytes(desc).length <= 540);
        ClubData.setClubDescribe(desc);
    }

    function setClubDescAndReportLimit(string desc, uint256 reportLimit) 
        public 
        onlyOwner() 
    {
        require(bytes(desc).length > 0 && bytes(desc).length <= 540);
        ClubData.setClubDescribe(desc);
        ClubData.setReportLimit(reportLimit);
    }

    function join()
        public
    {
        require(ClubPlayer.getPlayerAddress(msg.sender) == msg.sender);
        require(!ClubData.signUps(msg.sender));
        ClubPlayer.joinClub(msg.sender, myDataAddress);
        ClubData.addMember(msg.sender);
    }

    function exit()
        isSignUp()
        public
    {
        require(msg.sender != ClubData.owner());
        ClubData.removeMember(msg.sender);
        ClubData.setMemberBonus(msg.sender, 0);
    }

    function getMembersLength()
        public
        view
        returns (uint256)
    {
        return ClubData.getMemberLength();
    }

    function checkin(string imgUrl, string info)
        public
        isSignUp()
    {
        require(bytes(imgUrl).length != 0 || bytes(info).length != 0);
        uint256 time = now;

        ClubData.addCheckinEvent(msg.sender, info, imgUrl, time);

        ClubData.addCheckinEventId(time);

        ClubData.setMemberBonus(msg.sender, SafeMath.add(ClubData.getMemberBonus(ClubData.round(), msg.sender), ClubData.singleBonus()));
    }

    //get number of checkin events
    function getCheckinEventSize()
        public
        view
        returns (uint256)
    {
        return ClubData.getCheckinEventIdsLength();
    }

    //suppot a checkin event
    function support(uint256 id)
        public
        checkinEventExist(ClubData.round(), id)
    {
        //cannot support if the user does not registered
        require(ClubPlayer.checkIfRegistered(msg.sender));
        //cannot support if the event is already reported
        require(!ClubData.getEventPunishState(ClubData.round(), id));
        //cannot support event that is created by the sender
        require(ClubData.getEventAuthor(ClubData.round(), id) != msg.sender);

        //the same person cannot support the same event repeatedly
        for (uint256 i = 0; i < ClubData.getEventSupports(ClubData.round(), id).length; i++) {
            if (ClubData.getEventSupports(ClubData.round(), id)[i] == msg.sender) {
                revert();
            }
        }

        ClubData.supportEvent(id, msg.sender);

        address eventAuthor = ClubData.getEventAuthor(ClubData.round(), id);
        ClubData.setMemberBonus(eventAuthor, SafeMath.add(ClubData.getMemberBonus(ClubData.round(), eventAuthor), ClubData.supportBonus()));
    }

    function getSupport(uint256 id)
        public
        view
        checkinEventExist(ClubData.round(), id)
        returns (address[])
    {
        return ClubData.getEventSupports(ClubData.round(), id);
    }

    function report(uint256 id)
        public
        isSignUp()
        checkinEventExist(ClubData.round(), id)
    {
        require(!ClubData.getEventPunishState(ClubData.round(), id));
        ClubData.reportEvent(id, msg.sender);

        if (ClubData.getEventReports(ClubData.round(), id).length >= ClubData.reportLimit()) {
            ClubData.punish(id);
            address eventAuthor = ClubData.getEventAuthor(ClubData.round(), id);
            if (ClubData.getMemberBonus(ClubData.round(), eventAuthor) <= ClubData.punishBonus()) {
                ClubData.setMemberBonus(eventAuthor, 0);
            } else {
                ClubData.setMemberBonus(eventAuthor, SafeMath.sub(ClubData.getMemberBonus(ClubData.round(), eventAuthor), ClubData.punishBonus()));
            }
        }
    }

    function getReportSize(uint256 id)
        public
        view
        checkinEventExist(ClubData.round(), id)
        returns (uint256)
    {
        return ClubData.getEventReports(ClubData.round(), id).length;
    }

    //round-related manipulations
    function clear()
        public
        onlyOwner()
    {
        //instantiate ERC tokens with address
        Erc20 ClubToken = Erc20(ClubData.tokenAddress());

        //get total tokens
        uint256 token = ClubToken.balanceOf(returnContractAddress());
        require(token > 0);

        //clear members that exited
        address[] memory allMembersInRound = new address[](getMembersLength());
        uint256 length = 0;
        for (uint256 i = 0; i < getMembersLength(); i++) {
            if (ClubData.signUps(ClubData.getMembers()[i])) {
                allMembersInRound[i] = ClubData.getMembers()[i];
                length = SafeMath.add(length, 1);
            }
        }

        ClubData.deleteMember();

        for (uint256 m = 0; m < length; m++) {
            ClubData.addMember(allMembersInRound[m]);
        }

        //calculate total bonus
        uint256 totalBonus = 0;
        for (uint256 x = 0; x < ClubData.getMembers().length; x++) {
            totalBonus = SafeMath.add(totalBonus, ClubData.getMemberBonus(ClubData.round(), ClubData.getMembers()[x]));
        }

        require(totalBonus > 0);

        //distribute bonus
        uint256 remainder = token % totalBonus;
        uint256 tokensPerBonus = (token - remainder) / totalBonus;
        for (uint256 y = 0; y < ClubData.getMembers().length; y++) {
            if (ClubData.getMembers()[y] == ClubData.owner()) {
                //remainder will be owned by admin
                ClubToken.transfer(ClubData.owner(), SafeMath.add(ClubData.getMemberBonus(ClubData.round(), ClubData.owner()) * tokensPerBonus, remainder));
            } else {
                ClubToken.transfer(ClubData.getMembers()[y], ClubData.getMemberBonus(ClubData.round(), ClubData.getMembers()[y]) * tokensPerBonus);
            }
        }

        ClubData.addHistory(totalBonus, token);
        //start next round
        ClubData.setRound(SafeMath.add(ClubData.round(), 1));
        ClubData.setEventSize(0);
    }

    function returnContractAddress()
        private
        view
        returns (address)
    {
        return this;
    }
}
