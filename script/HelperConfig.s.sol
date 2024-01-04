//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';

contract HelperConfig is Script{

    NetworkConfig public activeConfig;

   struct NetworkConfig{
      address _decAddress;
   }

   constructor(){
    if(block.chainid == 11155111){
       activeConfig = getSepoliaChain();
    }else{
        activeConfig = getOrCreateAnvilChain();
    }
   }

   function getSepoliaChain() public pure returns (NetworkConfig memory){
     NetworkConfig memory sepoliaConfig = NetworkConfig({
        _decAddress : 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
     });

     return sepoliaConfig;
   }

   function getOrCreateAnvilChain() public pure returns (NetworkConfig memory){
    NetworkConfig memory anvilConfig = NetworkConfig({
       _decAddress : address(1)
    });
    return anvilConfig;
   }
  
}