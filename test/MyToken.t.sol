// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployMyToken} from "script/DeployMyToken.s.sol";
import {MyToken} from "src/MyToken.sol";

contract OurTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");

    uint256 public constant STARTING_BALANCE = 120 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, myToken.balanceOf(bob));
    }

    function testAllowanceWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice  to send tokens on his behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferWorks() public {
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        myToken.transfer(alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    // function testTransferFailsIfInsufficientBalance() public {
    //     vm.expectRevert("ERC20: transfer amount exceeds balance");

    //     vm.prank(alice);
    //     myToken.transfer(bob, 1 ether);
    // }

    function testApproveAndTransferFromWorks() public {
        uint256 approveAmount = 100 ether;

        // Bob approves Alice to spend tokens
        vm.prank(bob);
        myToken.approve(alice, approveAmount);

        // Alice transfers on behalf of Bob
        uint256 transferAmount = 60 ether;
        vm.prank(alice);
        myToken.transferFrom(bob, carol, transferAmount);

        assertEq(myToken.balanceOf(carol), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(myToken.allowance(bob, alice), approveAmount - transferAmount);
    }

    // function testTransferFromFailsIfNotApproved() public {
    //     vm.expectRevert("ERC20: insufficient allowance");

    //     vm.prank(alice);
    //     myToken.transferFrom(bob, carol, 1 ether);
    // }

    // function testTransferFromFailsIfOverApprovedAmount() public {
    //     uint256 approveAmount = 5 ether;
    //     vm.prank(bob);
    //     myToken.approve(alice, approveAmount);

    //     vm.expectRevert("ERC20: insufficient allowance");

    //     vm.prank(alice);
    //     myToken.transferFrom(bob, carol, 10 ether);
    // }

    function testApproveOverwrite() public {
        vm.prank(bob);
        myToken.approve(alice, 10 ether);
        vm.prank(bob);
        myToken.approve(alice, 20 ether); // overwrites previous

        assertEq(myToken.allowance(bob, alice), 20 ether);
    }

    // function testIncreaseDecreaseAllowance() public {
    //     vm.prank(bob);
    //     myToken.approve(alice, 10 ether);

    //     vm.prank(bob);
    //     myToken.increaseAllowance(alice, 5 ether);
    //     assertEq(myToken.allowance(bob, alice), 15 ether);

    //     vm.prank(bob);
    //     myToken.decreaseAllowance(alice, 3 ether);
    //     assertEq(myToken.allowance(bob, alice), 12 ether);
    // }

    // function testCannotDecreaseAllowanceBelowZero() public {
    //     vm.prank(bob);
    //     myToken.approve(alice, 2 ether);

    //     vm.expectRevert("ERC20: decreased allowance below zero");
    //     vm.prank(bob);
    //     myToken.decreaseAllowance(alice, 3 ether);
    // }

    function testTransferZeroTokens() public {
        vm.prank(bob);
        bool success = myToken.transfer(alice, 0);
        assertTrue(success);
    }

    function testApproveZero() public {
        vm.prank(bob);
        bool success = myToken.approve(alice, 0);
        assertTrue(success);
        assertEq(myToken.allowance(bob, alice), 0);
    }

    function testEventsOnTransfer() public {
        uint256 transferAmount = 5 ether;
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount);

        vm.prank(bob);
        myToken.transfer(alice, transferAmount);
    }

    function testEventsOnApprove() public {
        uint256 approveAmount = 10 ether;
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, approveAmount);

        vm.prank(bob);
        myToken.approve(alice, approveAmount);
    }

    // Events for validation
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


}
