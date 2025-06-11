// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // I used this so that it can supply ERC20 functionalities in my MyToken contract.

contract MyToken is ERC20 {
    constructor(uint256 startingSupply) ERC20("MyToken", "MT") {
        _mint(msg.sender, startingSupply); //specifies the address that will receive the newly minted tokens,in our case it is msg.sender
    }
}
