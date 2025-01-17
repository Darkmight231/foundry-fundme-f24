//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

contract IntegrationsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 * 1e18;
    uint256 constant STARTING_BALANCE = 1e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        (fundMe, ) = deploy.run();
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
        // vm.prank(USER);

        // fundMe.fund{value: SEND_VALUE}();
        // // FundFundMe fund = new FundFundMe();
        // // fund.fundFundMe(address(fundMe));

        // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // withdrawFundMe.withdrawFundMe(address(fundMe));

        // assert(address(fundMe).balance == 0);
    }
}
