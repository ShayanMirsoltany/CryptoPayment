//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@utils/Errors.sol";
import "@erc20/CLT_Token.sol";
import { Test, console } from "forge-std/Test.sol";
import "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
contract CLT_TokenTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);

    address owner;
    address minter;
    address burner;
    address spender;
    address addr1;
    address addr2;
    CLT_Token public token;
    address proxy;
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
        token = new CLT_Token();
        bytes memory data = abi.encodeCall(token.initialize, ("Chainlinker", "CLT", 100_000_000 ether));
        proxy = address(new ERC1967Proxy(address(token), data));
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        CLT_Token(proxy).mint(minter, 1000);
        assertEq(CLT_Token(proxy).balanceOf(minter), 1000);
        vm.stopPrank();

        // vm.startPrank(minter);
        // CLT_Token(proxy).burn(100);
        // assertEq(CLT_Token(proxy).balanceOf(minter), 900);
        // vm.stopPrank();
    }
    // function test_Balance() public {
    //     vm.startPrank(owner);
    //     CLT_Token(proxy).mint(minter, 1000);
    //     assertEq(CLT_Token(proxy).balanceOf(minter), 1000);
    //     vm.stopPrank();
    // }

    // function test_TransferFrom() public {
    //     vm.startPrank(owner);
    //     CLT_Token(proxy).mint(minter, 1000);
    //     assertEq(CLT_Token(proxy).balanceOf(minter), 1000);

    //     vm.startPrank(minter);
    //     CLT_Token(proxy).approve(spender, 100);
    //     vm.stopPrank();

    //     vm.startPrank(spender);
    //     assertEq(CLT_Token(proxy).allowance(minter, spender), 100);
    //     vm.expectEmit(true, true, false, true);
    //     emit Transfer(minter, spender, 100);
    //     CLT_Token(proxy).transferFrom(minter, spender, CLT_Token(proxy).allowance(minter, spender));
    //     vm.stopPrank();
    // }

    // function testBurnFrom() public {
    //     vm.startPrank(owner);
    //     CLT_Token(proxy).mint(minter, 1000);
    //     assertEq(CLT_Token(proxy).balanceOf(minter), 1000);
    //     vm.stopPrank();

    //     vm.startPrank(minter);
    //     CLT_Token(proxy).approve(owner, 100);
    //     vm.stopPrank();

    //     vm.startPrank(owner);
    //     CLT_Token(proxy).burnFrom(minter, 100);
    //     assertEq(CLT_Token(proxy).balanceOf(minter), 900);
    //     vm.stopPrank();
    // }

    // function testPause() public {
    //     vm.startPrank(owner);
    //     CLT_Token(proxy).mint(minter, 1000);
    //     assertEq(CLT_Token(proxy).balanceOf(minter), 1000);
    //     vm.stopPrank();

    //     vm.startPrank(owner);
    //     CLT_Token(proxy).pause();
    //     assertEq(CLT_Token(proxy).paused(), true);

    //     vm.expectRevert();
    //     CLT_Token(proxy).transfer(minter, 100);

    //     CLT_Token(proxy).unpause();
    //     CLT_Token(proxy).approve(minter, 100);
    //     assertEq(CLT_Token(proxy).allowance(owner, minter), 100);
    //     vm.stopPrank();
    // }
}
