//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import { Test, console } from "forge-std/Test.sol";

contract CLT_TokenTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    address owner;
    address minter;
    address burner;
    address spender;
    address addr1;
    address addr2;
    CLT_Token public tc;

    constructor() {
        owner = vm.addr(100);
        minter = vm.addr(101);
        burner = vm.addr(102);
        spender = vm.addr(103);
        addr1 = vm.addr(104);
        addr2 = vm.addr(105);

        vm.deal(owner, 100 ether);
        vm.deal(minter, 100 ether);
        vm.deal(burner, 100 ether);
        vm.deal(spender, 100 ether);
        vm.deal(addr1, 100 ether);
        vm.deal(addr2, 100 ether);
    }

    function setUp() public {
        vm.startPrank(owner);
        tc = new CLT_Token("Test Coin", "TC", 10000);
        vm.stopPrank();
    }

    function test_Balance() public {
        vm.startPrank(owner);
        tc.mint(minter, 1000);
        assertEq(tc.balanceOf(minter), 1000);
        vm.stopPrank();
    }

    function test_TransferFrom() public {
        vm.startPrank(owner);
        tc.mint(minter, 1000);
        assertEq(tc.balanceOf(minter), 1000);

        vm.startPrank(minter);
        tc.approve(spender, 100);
        vm.stopPrank();

        vm.startPrank(spender);
        assertEq(tc.allowance(minter, spender), 100);
        vm.expectEmit(true, true, false, true);
        emit Transfer(minter, spender, 100);
        tc.transferFrom(minter, spender, tc.allowance(minter, spender));
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        tc.mint(minter, 1000);
        assertEq(tc.balanceOf(minter), 1000);
        vm.stopPrank();

        vm.startPrank(minter);
        tc.burn(100);
        assertEq(tc.balanceOf(minter), 900);
        vm.stopPrank();
    }

    function testBurnFrom() public {
        vm.startPrank(owner);
        tc.mint(minter, 1000);
        assertEq(tc.balanceOf(minter), 1000);
        vm.stopPrank();

        vm.startPrank(minter);
        tc.approve(owner, 100);
        vm.stopPrank();

        vm.startPrank(owner);
        tc.burnFrom(minter, 100);
        assertEq(tc.balanceOf(minter), 900);
        vm.stopPrank();
    }

    function testPause() public {
        vm.startPrank(owner);
        tc.mint(minter, 1000);
        assertEq(tc.balanceOf(minter), 1000);
        vm.stopPrank();

        vm.startPrank(owner);
        tc.pause();
        assertEq(tc.paused(), true);

        vm.expectRevert();
        tc.transfer(minter, 100);

        tc.unpause();
        tc.approve(minter, 100);
        assertEq(tc.allowance(owner, minter), 100);
        vm.stopPrank();
    }
}
