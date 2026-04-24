// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./MyTokenBase.sol";

contract MyToken is MyTokenBase {
    string public name;
    string public symbol;
    address public owner;

    event Paused(address by);
    event Unpaused(address by);

    constructor(string memory _name, string memory _symbol, uint256 initialSupply) {
        name = _name;
        symbol = _symbol;
        balances[msg.sender] = initialSupply;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function pause() public onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function _calculateFee(uint256 amount) internal pure override returns (uint256) {
        return amount / 100; // 1% fee
    }
}
