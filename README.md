## Decentralized Staking Contract
# Overview

The Decentralized Staking Contract is a smart contract implemented in Solidity that allows users to stake tokens and earn rewards over a specific staking period. The contract is designed to be flexible, supporting functionalities such as depositing, withdrawing, collecting rewards, reinvesting rewards, and distributing rewards among stakers.
Features

   - Staking: Users can stake tokens on the contract by calling the deposit function.
   - Withdrawal: Stakers can withdraw their staked tokens using the withdraw function.
   - Reward Collection: Stakers can collect their earned rewards using the collect function.
   - Reinvestment: Rewards can be automatically reinvested by calling the restake function.
   - Reward Distribution: The contract owner can distribute rewards among stakers using the distributeRewards function.
   - Staker Information: Staker information, including balance, deposit time, and cumulative rewards, can be retrieved using the appropriate getter functions.
   - Flexible Reward Calculation: Rewards are calculated based on the staking duration, with different rates for varying time periods.

# Prerequisites

    Ethereum environment with Solidity compiler version ^0.8.18.
    ERC-20 token (e.g., Dec token) for staking.

# Getting Started

    Deploy the DecentralizedStake contract to the Ethereum blockchain, providing the ERC-20 token address during deployment.
    Users can interact with the contract by depositing, withdrawing, collecting rewards, or reinvesting.
    The contract owner can distribute rewards among stakers using the distributeRewards function.

