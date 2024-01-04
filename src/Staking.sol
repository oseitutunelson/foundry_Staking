// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title Staking and Reward Contract
 * @author Owusu Nelson Osei Tutu
 * @notice This contract allows users to stake tokens and get rewards after a certain time
 */

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedStake {
    using SafeMath for uint256;

    /* Events */
    event Deposit(address indexed _from, uint256 indexed _amount);
    event Withdraw(address indexed _to, uint256 _amount);
    event Collected(address indexed sender, uint256 reward);
    event DividendPaid(uint256 indexed amount);

    //staker information
    struct Staker {
        uint256 balance;
        uint256 depositTime;
        uint256 cummulatedRewards;
    }
    /* State Variables */
    //keep track of stakers and thier info

    mapping(address => Staker) public stakers;
    uint256 private stakerCount;
    uint256 private totalStaked;
    uint256 private totalRewarded;
    address[] public stakersArray;
    uint256 public constant YEAR_IN_SECONDS = 31536000;
    uint256 public constant SIX_MONTHS_IN_SECONDS = 15768000;
    uint256 public constant THREE_MONTHS_IN_SECONDS = 7884000;
    uint256 public constant ONE_MONTH_IN_SECONDS = 2628000;
    uint256 public constant ONE_WEEK_IN_SECONDS = 604800;
    address public decAddress;
    IERC20 public dec;

    constructor(address _decAddress) {
        decAddress = _decAddress;
        dec = IERC20(_decAddress);
    }

    //deposit function
    //deposits directly if user is new
    //transfers rewards to user if user already has balance and rewards
    function deposit(uint256 amount) external {
        Staker storage staker = stakers[msg.sender];
        address thisAddress = address(this);
        address from = msg.sender;

        if (staker.balance > 0 && staker.cummulatedRewards > 0) {
            dec.transfer(msg.sender, staker.cummulatedRewards);
            staker.balance = staker.balance.add(amount);
            dec.transferFrom(from, thisAddress, amount);
        } else {
            dec.transferFrom(from, thisAddress, amount);
            staker.balance = amount;
            stakersArray.push(from);
            stakerCount++;
            staker.depositTime = block.timestamp;
        }
        totalStaked = totalStaked.add(amount);
        emit Deposit(msg.sender, amount);
    }

    //withdraw tokens
    function withdraw(uint256 amount) external {
        address sender = msg.sender;
        Staker storage staker = stakers[sender];
        address thisAddress = address(this);

        require(staker.balance >= amount, "Insufficient balance");
        require(amount > 0, "Amount must be greater than zero");

        dec.transfer(sender, amount);

        staker.balance = staker.balance.sub(amount);
        totalStaked = totalStaked.sub(amount);
        staker.depositTime = block.timestamp;
        emit Withdraw(thisAddress, amount);
    }
    //collect rewards

    function collect() external {
        address sender = msg.sender;
        Staker storage staker = stakers[sender];
        uint256 reward = staker.cummulatedRewards;

        require(reward > 0, "Nothing to collect");

        dec.transfer(sender, reward);
        staker.cummulatedRewards = 0; // Reset cumulative rewards to zero
        emit Collected(sender, reward);
    }
    // reinvest rewards

    function restake() external {
        address sender = msg.sender;
        Staker storage staker = stakers[sender];
        uint256 reward = staker.cummulatedRewards;

        require(reward >= 0, "Nothing to collect");

        staker.balance = staker.balance.add(reward);
        staker.cummulatedRewards = 0;

        emit Deposit(msg.sender, reward);
    }

    //distributing rewards
    function distributeRewards(uint256 rewardAmount) external {
        require(totalStaked > 0, "No stakers to distribute rewards");
        require(rewardAmount > 0, "Reward amount must be greater than zero");

        uint256 currentTime = block.timestamp;
        uint256 totalRewards = rewardAmount;
        uint256 paidRewards;
        uint256 totalRewardPaid;

        for (uint256 i = 0; i < stakersArray.length; i++) {
            address stakerAddress = stakersArray[i];
            Staker storage staker = stakers[stakerAddress];

            if (staker.balance > 0) {
                uint256 stakerRewards = calculateStakerRewards(staker, currentTime, totalRewards);

                // Add rewards to staker's balance and cumulative rewards
                staker.cummulatedRewards = staker.cummulatedRewards.add(stakerRewards);
                paidRewards = paidRewards.add(stakerRewards);
            }
        }

        uint256 amountToTransfer = totalRewards.sub(paidRewards);
        dec.transferFrom(msg.sender, address(this), amountToTransfer);
        totalRewardPaid = totalRewardPaid.add(amountToTransfer);
        emit DividendPaid(amountToTransfer);
    }
    //calculate staker rewards

    function calculateStakerRewards(Staker storage staker, uint256 currentTime, uint256 totalRewards)
        internal
        view
        returns (uint256)
    {
        uint256 stakingPeriod = currentTime.sub(staker.depositTime);

        if (stakingPeriod >= YEAR_IN_SECONDS) {
            return totalRewards;
        } else if (stakingPeriod >= SIX_MONTHS_IN_SECONDS) {
            return totalRewards.mul(staker.balance).mul(75).div(totalStaked).div(100);
        } else if (stakingPeriod >= THREE_MONTHS_IN_SECONDS) {
            return totalRewards.mul(staker.balance).mul(50).div(totalStaked).div(100);
        } else if (stakingPeriod >= ONE_MONTH_IN_SECONDS) {
            return totalRewards.mul(staker.balance).mul(25).div(totalStaked).div(100);
        } else if (stakingPeriod >= ONE_WEEK_IN_SECONDS) {
            return totalRewards.mul(staker.balance).mul(10).div(totalStaked).div(100);
        } else {
            return totalRewards.mul(staker.balance).mul(5).div(totalStaked).div(100);
        }
    }

    //retrieve staker information
    function getStaker(address _address)
        external
        view
        returns (uint256 balance, uint256 depositTime, uint256 cumulativeRewards)
    {
        Staker storage staker = stakers[_address];
        return (staker.balance, staker.depositTime, staker.cummulatedRewards);
    }

    //check if an address is a staker
    function isStaker(address _address) external view returns (bool) {
        return stakers[_address].balance > 0;
    }

    //retrieve accumulated reward for a specific address
    function getReward(address _address) external view returns (uint256) {
        Staker storage staker = stakers[_address];
        uint256 reward = staker.cummulatedRewards;
        return reward;
    }

    /** Getter functions */
    function getTotalStaked() external view returns (uint256){
        return totalStaked;
    }

    function getTotalRewarded() external view returns (uint256){
        return totalRewarded;
    }

    function getStakerCount() external view returns (uint256){
        return stakerCount;
    }
}
