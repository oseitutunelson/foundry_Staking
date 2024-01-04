//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {DecentralizedStake} from '../src/Staking.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployStaking is Script{
    HelperConfig helperConfig = new HelperConfig();
    address decAddress = helperConfig.activeConfig();

    function run() external returns (DecentralizedStake){
        vm.startBroadcast();
        DecentralizedStake decStake = new DecentralizedStake(decAddress);
        vm.stopBroadcast();

        return decStake;
    }
}