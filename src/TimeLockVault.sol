// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TimeLockVault {

    struct Deposit {
        uint256 amount;
        uint256 unlockTimeInSeconds;
    }

    mapping(address => Deposit) public deposits;

    function deposit(uint256 lockTimeInSeconds) external payable {
        require(msg.value > 0, "Value must be greater than 0");
        require(lockTimeInSeconds > 0, "Lock time must be greater than 0 seconds");
        require(lockTimeInSeconds <= 31536000, "Lock time must be less than or equal to 31536000 seconds (1 year)");
        require(deposits[msg.sender].amount == 0, "Already have locked ETH");

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            unlockTimeInSeconds: block.timestamp + lockTimeInSeconds
        });
    }

    function withdraw() external {
        Deposit memory userDeposit = deposits[msg.sender];

        require(userDeposit.amount > 0, "No funds deposited");
        require(block.timestamp >= userDeposit.unlockTimeInSeconds, "Funds are still locked");

        uint256 amount = userDeposit.amount;

        delete deposits[msg.sender];

        payable(msg.sender).transfer(amount);

    }

    function timeLeft() external view returns (uint256) {
        if (block.timestamp >= deposits[msg.sender].unlockTimeInSeconds) {
            return 0;
        }
        return deposits[msg.sender].unlockTimeInSeconds - block.timestamp;
    }

    function getDeposit(address user) external view returns (uint256) {
        return deposits[user].amount;
    }

    function getUnlockTime(address user) external view returns (uint256) {
        return deposits[user].unlockTimeInSeconds;
    }
}
