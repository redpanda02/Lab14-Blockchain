// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./IMyToken.sol";

abstract contract MyTokenBase is IMyToken {
    bool public paused;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    function getBalance(address user) public view override returns (uint256) {
        return balances[user];
    }

    // Child contracts must decide how the fee is calculated.
    function _calculateFee(uint256 amount) internal virtual pure returns (uint256);

    modifier whenNotPaused() {
        require(!paused, "Transfers are paused");
        _;
    }

    function transfer(address to, uint256 amount) public override whenNotPaused {
        uint256 fee = _calculateFee(amount);
        require(balances[msg.sender] >= amount + fee, "Insufficient balance");
        balances[msg.sender] -= amount + fee;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) public override {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused {
        uint256 fee = _calculateFee(amount);
        require(allowances[from][msg.sender] >= amount + fee, "Allowance insufficient");
        require(balances[from] >= amount + fee, "Insufficient balance");
        allowances[from][msg.sender] -= amount + fee;
        balances[from] -= amount + fee;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }
}
