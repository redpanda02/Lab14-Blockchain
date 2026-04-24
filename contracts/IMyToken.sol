// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IMyToken {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    function transfer(address to, uint256 amount) external;
    function getBalance(address user) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external;
}
