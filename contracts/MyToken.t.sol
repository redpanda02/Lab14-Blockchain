// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MyToken} from "./MyToken.sol";
import {Test} from "forge-std/Test.sol";

contract MyTokenTest is Test {
  MyToken token;

  function setUp() public {
    token = new MyToken("MyToken", "MTK", 1000000);
  }

  function test_InitialSupply() public view {
    require(token.getBalance(address(this)) == 1000000, "Initial supply should be 1000000");
  }

  function test_Transfer() public {
    address recipient = address(0x123);
    token.transfer(recipient, 1000);
    require(token.getBalance(address(this)) == 1000000 - 1000 - 10, "Sender balance after transfer");
    require(token.getBalance(recipient) == 1000, "Recipient balance after transfer");
  }

  function test_Approve() public {
    address spender = address(0x456);
    token.approve(spender, 500);
    require(token.allowance(address(this), spender) == 500, "Allowance should be 500");
  }

  function test_TransferFrom() public {
    address spender = address(0x456);
    address recipient = address(0x789);
    token.approve(spender, 500);
    vm.prank(spender);
    token.transferFrom(address(this), recipient, 100);
    require(token.getBalance(address(this)) == 1000000 - 100 - 1, "Sender balance after transferFrom");
    require(token.getBalance(recipient) == 100, "Recipient balance after transferFrom");
    require(token.allowance(address(this), spender) == 500 - 100 - 1, "Allowance after transferFrom");
  }

  function test_Pause() public {
    token.pause();
    require(token.paused() == true, "Should be paused");
    vm.expectRevert();
    token.transfer(address(0x123), 100);
    token.unpause();
    require(token.paused() == false, "Should be unpaused");
  }
}