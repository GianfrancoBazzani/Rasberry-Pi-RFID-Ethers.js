// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./FareCalculator.sol";
import "./AccessControlToken.sol";

/* TO DO LIST;
    - posar camps privat
    - getCurrentFare y getFare()
    - checkejar que la interface es d'un cert tipus
    - batched versions com future qork
    - posar camps privats privats
    - comentaris
*/
contract AccessControl is Ownable {
    event UserBlocked(address indexed userAddress_, uint256 indexed debt);
    event UserUnblocked(address indexed userAddress_);
    event NewFare(address indexed fareAddress_);
    event DebtPayed(address indexed userAdrdress_);

    enum Status {
        BLOCKED,
        ACTIVATED
    }
    struct UserData {
        Status status;
        uint256[] registers;
        uint256 autentificator;
        bool isInside;
        uint256 debt;
    }

    mapping(address => uint256) public userID;
    UserData[] public user;
    uint256 public nUsers;
    AccessControlToken public token;

    FareCalculator[] public fare;
    uint256[] public fareTimeStamp;

    address public hardwareAddress;
    bool public onchainTime;

    /**
     * modifiers
     */
    modifier onlyHardware() {
        require(msg.sender == hardwareAddress, "You're not the hardware");
        _;
    }

    modifier onlyRegistered(address userAddress_) {
        require(userID[userAddress_] > 0, "This user is not registered");
        _;
    }

    modifier onlyActivated(address userAdress_) {
        require(
            userID[userAdress_] > 0 &&
                user[userID[userAdress_] - 1].status == Status.ACTIVATED,
            "This user is not activated"
        );
        _;
    }

    modifier onlyOnchainTime() {
        require(onchainTime == true, "The onchainTime value should be true");
        _;
    }

    modifier onlyOffchainTime() {
        require(onchainTime == false, "The onchainTime value should be false");
        _;
    }

    modifier onlyOutside(address userAddress_) {
        UserData storage tmpUser = user[userID[userAddress_] - 1];
        require(
            (tmpUser.registers).length % 2 == 0 && !tmpUser.isInside,
            "The user is not outside"
        );
        _;
    }

    modifier onlyInside(address userAddress_) {
        UserData storage tmpUser = user[userID[userAddress_] - 1];
        require(
            (tmpUser.registers).length % 2 == 1 && tmpUser.isInside,
            "The user is not inside"
        );
        _;
    }

    /**
     * constructor and users/fares managment
     */

    constructor(
        address hardwareAddress_,
        address tokenAddress_,
        bool onchainTime_
    ) {
        hardwareAddress = hardwareAddress_;
        onchainTime = onchainTime_;
        token = AccessControlToken(tokenAddress_);
        nUsers = 0;
    }

    function addUser(address userAddress_) public onlyOwner {
        require(userID[userAddress_] == 0, "User already added");
        user.push();
        nUsers += 1;
        userID[userAddress_] = nUsers;
        UserData storage tmpUser = user[nUsers - 1];
        tmpUser.status = Status.ACTIVATED;
        tmpUser.isInside = false;
    }

    function setAutentificator(uint256 newAutentificator_)
        public
        onlyActivated(msg.sender)
    {
        UserData storage tmpUser = user[userID[msg.sender] - 1];
        tmpUser.autentificator = newAutentificator_;
    }

    function blockUser(address userAdrdress_)
        public
        onlyOwner
        onlyActivated(userAdrdress_)
    {
        user[userID[userAdrdress_] - 1].status = Status.BLOCKED;
        emit UserBlocked(userAdrdress_, 0);
    }

    function unblockUser(address userAdrdress_)
        public
        onlyOwner
        onlyRegistered(userAdrdress_)
    {
        UserData storage tmpUser = user[userID[userAdrdress_] - 1];
        require(tmpUser.status == Status.BLOCKED, "The user is not blocked");
        tmpUser.status = Status.ACTIVATED;
        emit UserUnblocked(userAdrdress_);
    }

    function addFare(address fareAddress_) public onlyOwner {
        //rick: aqui em falta comprobar que implementa la interface
        fareTimeStamp.push(block.timestamp);
        fare.push(FareCalculator(fareAddress_));
        emit NewFare(fareAddress_);
    }

    /**
     * accesses registry
     */
    function enter(address userAddress_)
        public
        onlyRegistered(userAddress_)
        onlyOnchainTime
        onlyOutside(userAddress_)
    {
        _register(userAddress_, block.timestamp);
    }

    function exit(address userAddress_)
        public
        onlyRegistered(userAddress_)
        onlyOnchainTime
        onlyInside(userAddress_)
    {
        _register(userAddress_, block.timestamp);
    }

    function register(address userAddress_)
        public
        onlyRegistered(userAddress_)
        onlyOnchainTime
    {
        _register(userAddress_, block.timestamp);
    }

    function enter(address userAddress_, uint256 timestamp_)
        public
        onlyRegistered(userAddress_)
        onlyOffchainTime
        onlyOutside(userAddress_)
    {
        _register(userAddress_, timestamp_);
    }

    function exit(address userAddress_, uint256 timestamp_)
        public
        onlyRegistered(userAddress_)
        onlyOffchainTime
        onlyInside(userAddress_)
    {
        _register(userAddress_, timestamp_);
    }

    function register(address userAddress_, uint256 timestamp_)
        public
        onlyRegistered(userAddress_)
        onlyOffchainTime
    {
        _register(userAddress_, timestamp_);
    }

    /**
     * pay debt
     */
    function myDebt() public view onlyRegistered(msg.sender) returns (uint256) {
        return user[userID[msg.sender] - 1].debt;
    }

    function payDebt(uint256 amount_) public onlyRegistered(msg.sender) {
        uint256 debt = user[userID[msg.sender] - 1].debt;
        if (debt < amount_) {
            amount_ = debt;
        }
        if (amount_ > 0) {
            bool sent = token.transferFrom(msg.sender, this.owner(), amount_);
            require(sent, "Failed to pay debt");
            user[userID[msg.sender] - 1].debt = debt - amount_;
            emit DebtPayed(msg.sender);
        }
    }

    /**
     * view functions
     */
    function getUserRegisters(address userAddress_)
        public
        view
        onlyRegistered(userAddress_)
        returns (uint256[] memory)
    {
        return user[userID[userAddress_] - 1].registers;
    }

    function isInside(address userAddress_)
        public
        view
        onlyRegistered(userAddress_)
        onlyOnchainTime
        returns (bool)
    {
        return user[userID[userAddress_] - 1].isInside;
    }

    function isInside(address userAddress_, uint256 timestamp_)
        public
        view
        onlyRegistered(userAddress_)
        onlyOffchainTime
        returns (bool)
    {
        return _isInsideID(userID[userAddress_] - 1, timestamp_);
    }

    function occupancy() public view returns (uint256) {
        return occupancy(block.timestamp);
    }

    function occupancy(uint256 timestamp_) public view returns (uint256) {
        uint256 nInside = 0;
        for (uint256 i = 0; i < nUsers; ++i) {
            if (_isInsideID(i, timestamp_)) {
                nInside += 1;
            }
        }
        return nInside;
    }

    function occupancy(uint256 start_, uint256 end_)
        public
        view
        returns (uint256)
    {
        uint256 sum = 0;
        for (uint256 i = 0; i < nUsers; ++i) {
            sum += _timeInside(i, start_, end_);
        }
        return sum;
    }

    /**
     * internals
     */
    function _register(address userAddress_, uint256 timestamp_)
        internal
        onlyHardware
        onlyActivated(userAddress_)
    {
        UserData storage tmpUser = user[userID[userAddress_] - 1];
        tmpUser.isInside = !tmpUser.isInside;
        tmpUser.registers.push(timestamp_);

        if (!tmpUser.isInside) {
            uint256 nRegisters = tmpUser.registers.length;
            uint256 start_ = tmpUser.registers[nRegisters - 2];
            uint256 stop_ = tmpUser.registers[nRegisters - 1];
            _exitAction(userAddress_, start_, stop_, occupancy(start_, stop_));
        }
    }

    function _timeInside(
        uint256 userID_,
        uint256 start_,
        uint256 end_
    ) internal view returns (uint256) {
        require(
            userID_ >= 0 && userID_ < nUsers,
            "Out of range access to user"
        );
        require(start_ < end_, "This is not an interval");
        uint256 interval = end_ - start_;
        uint256 sum = 0;
        UserData storage tmpUser = user[userID_];
        uint256 nRegisters = tmpUser.registers.length;
        uint256 maxA;
        uint256 minB;
        for (uint256 i = 0; i < nRegisters; i += 2) {
            maxA = tmpUser.registers[i];
            if (start_ > maxA) {
                maxA = start_;
            }
            if (i + 1 < tmpUser.registers.length) {
                minB = tmpUser.registers[i + 1];
            } else {
                minB = block.timestamp;
            }
            if (end_ < minB) {
                minB = end_;
            }
            if (minB > maxA) {
                sum += minB - maxA;
            }
        }
        return (sum + (interval) / 2) / interval;
    }

    function _isInsideID(uint256 userID_, uint256 timestamp_)
        internal
        view
        returns (bool)
    {
        require(
            userID_ >= 0 && userID_ < nUsers,
            "Out of range access to user"
        );
        bool isin = false;
        UserData storage tmpUser = user[userID_];
        uint256 nRegisters = tmpUser.registers.length;
        for (uint256 i = 0; i < nRegisters; i += 2) {
            if (timestamp_ >= tmpUser.registers[i]) {
                isin = true;
                if (
                    i + 1 < tmpUser.registers.length &&
                    timestamp_ > tmpUser.registers[i + 1]
                ) {
                    isin = false;
                }
            }
        }
        return isin;
    }

    function _exitAction(
        address userAddress_,
        uint256 start_,
        uint256 stop_,
        uint256 occupancy_
    ) internal {
        uint256 nFares = fare.length;
        uint256 cost = 0;
        for (uint256 i = 0; i < nFares; i++) {
            if (fareTimeStamp[nFares - 1 - i] < start_) {
                cost = fare[i].evaluate(
                    start_,
                    stop_,
                    occupancy_,
                    userAddress_,
                    address(this)
                );
                break;
            }
        }

        if (cost > 0) {
            UserData storage tmpUser = user[userID[userAddress_] - 1];
            tmpUser.debt += cost;
            tmpUser.status = Status.BLOCKED;
            uint256 allowance = token.allowance(userAddress_, address(this));
            if (allowance < cost) {
                emit UserBlocked(userAddress_, cost - allowance);
                cost = allowance;
            }
            if (cost > 0) {
                bool sent = token.transferFrom(
                    userAddress_,
                    this.owner(),
                    cost
                );
                require(sent, "Failed to pay on exit");
                tmpUser.debt -= cost;
                if (tmpUser.debt == 0) tmpUser.status = Status.ACTIVATED;
            }
        }
    }
}