// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorInterface.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SIA_Platform {
    error SwitchOff();
    error NotOwner(address owner, address caller);
    error NotPendingOwner(address pendingOwner, address caller);
    error ZeroAddress();
    error InvalidValue(uint required, uint actual);
    error InvalidPrice(int price);

    event CheckedIn(address indexed account, uint amount, uint remains);
    event CheckedInUSDT(address indexed account, uint amount);
    event AgentCreated(address indexed account, uint amount, uint remains);
    event AgentCreatedUSDT(address indexed account, uint amount);
    event AllianceCreated(address indexed account, uint amount, uint remains);
    event AllianceCreatedUSDT(address indexed account, uint amount);
    event USDTAddressChanged(address indexed new_usdtAddress);
    event PriceFeedAddressChanged(address indexed new_priceFeedAddress);
    event CheckInValueChanged(uint new_checkIn_amount);
    event AgentCreateValueChanged(uint new_agentCreate_amount);
    event AllianceCreateValueChanged(uint new_allianceCreate_amount);
    event SwitchChanged(bool new_switch);
    event ReceiverChanged(address indexed new_receiver);
    event PendingOwnerChanged(address indexed new_pendingOwner);
    event OwnerChanged(address indexed new_owner);

    ERC20 private _usdt;
    AggregatorInterface private _priceFeed;
    uint private _checkIn_amount;
    uint private _agentCreate_amount;
    uint private _allianceCreate_amount;
    address private _owner;
    address private _pendingOwner;
    address payable private _receiver;
    bool private _switch;

    uint constant DEFAULT_CHECKIN_AMOUNT = 1e6;
    uint constant DEFAULT_AGENT_CREATE_AMOUNT = 1e6;
    uint constant DEFAULT_ALLIANCE_CREATE_AMOUNT = 499000000;
    address constant DEFAULT_CHAINLINK_FEEDER = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BSC Mainnet BNB/USD
    address constant DEFAULT_USDT = 0x55d398326f99059fF775485246999027B3197955; // BSC Mainnet USDT

    constructor(address owner, address receiver) {
        if (owner == address(0) || receiver == address(0)) revert ZeroAddress();
        _checkIn_amount = DEFAULT_CHECKIN_AMOUNT;
        _agentCreate_amount = DEFAULT_AGENT_CREATE_AMOUNT;
        _allianceCreate_amount = DEFAULT_ALLIANCE_CREATE_AMOUNT;
        _usdt = ERC20(DEFAULT_USDT);
        _priceFeed = AggregatorInterface(DEFAULT_CHAINLINK_FEEDER);
        _receiver = payable(receiver);
        _owner = owner;
        _switch = true;
    }

    function checkIn() external payable switchOn {
        address sender = msg.sender;
        uint value = msg.value;
        uint requiredAmount = getCheckInAmount();
        if (value < requiredAmount) revert InvalidValue(requiredAmount, value);
        uint remains = value - requiredAmount;
        emit CheckedIn(sender, requiredAmount, remains);
        _receiver.transfer(requiredAmount);
        if (remains > 0) payable(sender).transfer(remains);
    }

    function checkInUSDT() external switchOn {
        address sender = msg.sender;
        uint amount = getCheckInAmountUSDT();
        emit CheckedInUSDT(sender, amount);
        _usdt.transferFrom(sender, _receiver, amount);
    }

    function agentCreate() external payable switchOn {
        address sender = msg.sender;
        uint value = msg.value;
        uint requiredAmount = getAgentCreateAmount();
        if (value < requiredAmount) revert InvalidValue(requiredAmount, value);
        uint remains = value - requiredAmount;
        emit AgentCreated(sender, requiredAmount, remains);
        _receiver.transfer(requiredAmount);
        if (remains > 0) payable(sender).transfer(remains);
    }

    function agentCreateUSDT() external switchOn {
        address sender = msg.sender;
        uint amount = getAgentCreateAmountUSDT();
        emit AgentCreatedUSDT(sender, amount);
        _usdt.transferFrom(sender, _receiver, amount);
    }

    function allianceCreate() external payable switchOn {
        address sender = msg.sender;
        uint value = msg.value;
        uint requiredAmount = getAllianceCreateAmount();
        if (value < requiredAmount) revert InvalidValue(requiredAmount, value);
        uint remains = value - requiredAmount;
        emit AllianceCreated(sender, requiredAmount, remains);
        _receiver.transfer(requiredAmount);
        if (remains > 0) payable(sender).transfer(remains);
    }

    function allianceCreateUSDT() external switchOn {
        address sender = msg.sender;
        uint amount = getAllianceCreateAmountUSDT();
        emit AllianceCreatedUSDT(sender, amount);
        _usdt.transferFrom(sender, _receiver, amount);
    }

    function getCheckInAmount() public view returns (uint) {
        return _calculateAmount(_checkIn_amount);
    }

    function getCheckInAmountUSDT() public view returns (uint) {
        return _calculateAmountUSDT(_checkIn_amount);
    }

    function getAgentCreateAmount() public view returns (uint) {
        return _calculateAmount(_agentCreate_amount);
    }

    function getAgentCreateAmountUSDT() public view returns (uint) {
        return _calculateAmountUSDT(_agentCreate_amount);
    }

    function getAllianceCreateAmount() public view returns (uint) {
        return _calculateAmount(_allianceCreate_amount);
    }

    function getAllianceCreateAmountUSDT() public view returns (uint) {
        return _calculateAmountUSDT(_allianceCreate_amount);
    }

    function getUSDTAddress() external view returns (address) {
        return address(_usdt);
    }

    function setUSDTAddress(address new_usdtAddress) external onlyOwner {
        if (new_usdtAddress == address(0)) revert ZeroAddress();
        _usdt = ERC20(new_usdtAddress);
        emit USDTAddressChanged(new_usdtAddress);
    }

    function getPriceFeedAddress() external view returns (address) {
        return address(_priceFeed);
    }

    function setPriceFeedAddress(
        address new_priceFeedAddress
    ) external onlyOwner {
        if (new_priceFeedAddress == address(0)) revert ZeroAddress();
        _priceFeed = AggregatorInterface(new_priceFeedAddress);
        emit PriceFeedAddressChanged(new_priceFeedAddress);
    }

    function getCheckInValue() external view returns (uint) {
        return _checkIn_amount;
    }

    function setCheckInValue(uint new_checkIn_amount) external onlyOwner {
        _checkIn_amount = new_checkIn_amount;
        emit CheckInValueChanged(new_checkIn_amount);
    }

    function getAgentCreateValue() external view returns (uint) {
        return _agentCreate_amount;
    }

    function setAgentCreateValue(
        uint new_agentCreate_amount
    ) external onlyOwner {
        _agentCreate_amount = new_agentCreate_amount;
        emit AgentCreateValueChanged(new_agentCreate_amount);
    }

    function getAllianceCreateValue() external view returns (uint) {
        return _allianceCreate_amount;
    }

    function setAllianceCreateValue(
        uint new_allianceCreate_amount
    ) external onlyOwner {
        _allianceCreate_amount = new_allianceCreate_amount;
        emit AllianceCreateValueChanged(new_allianceCreate_amount);
    }

    function getSwitch() external view returns (bool) {
        return _switch;
    }

    function setSwitch(bool new_switch) external onlyOwner {
        _switch = new_switch;
        emit SwitchChanged(new_switch);
    }

    function getReceiver() external view returns (address) {
        return _receiver;
    }

    function setReceiver(address new_receiver) external onlyOwner {
        if (new_receiver == address(0)) revert ZeroAddress();
        _receiver = payable(new_receiver);
        emit ReceiverChanged(new_receiver);
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    function getPendingOwner() external view returns (address) {
        return _pendingOwner;
    }

    function setOwner(address new_owner) external onlyOwner {
        if (new_owner == address(0)) revert ZeroAddress();
        _pendingOwner = new_owner;
        emit PendingOwnerChanged(new_owner);
    }

    function acceptOwnership() external onlyPendingOwner {
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit OwnerChanged(_owner);
    }

    modifier onlyPendingOwner() {
        address caller = msg.sender;
        if (caller != _pendingOwner)
            revert NotPendingOwner(_pendingOwner, caller);
        _;
    }

    modifier onlyOwner() {
        address caller = msg.sender;
        if (caller != _owner) revert NotOwner(_owner, caller);
        _;
    }

    modifier switchOn() {
        if (!_switch) revert SwitchOff();
        _;
    }

    function _calculateAmount(uint rawAmount) private view returns (uint) {
        int price = _priceFeed.latestAnswer();
        if (price <= 0) revert InvalidPrice(price);
        return (rawAmount * 1e18) / uint256(price);
    }

    function _calculateAmountUSDT(uint rawAmount) private view returns (uint) {
        return (rawAmount * (10 ** _usdt.decimals())) / 1e8;
    }
}
