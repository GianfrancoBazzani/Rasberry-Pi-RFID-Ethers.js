// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract FareCalculator {
    function evaluate(
        uint256 start_,
        uint256 stop_,
        uint256 occupancy_,
        address userAddress_
    ) public virtual returns (uint256);
}

contract Fare1 is FareCalculator {
    function evaluate(
        uint256 start_,
        uint256 stop_,
        uint256, /*occupancy_*/
        address /*userAddress_*/
    ) public pure override returns (uint256) {
        return 2*(stop_ - start_);
    }
}

contract Fare2 is FareCalculator {
    function evaluate(
        uint256 start_,
        uint256 stop_,
        uint256 occupancy_,
        address /*userAddress_*/
    ) public pure override returns (uint256) {
        uint256 cost = 10;
        uint256 elapsedTime = stop_ - start_;
        if (occupancy_ < 100) {
            cost += 1 * elapsedTime;
        } else {
            cost += 2 * elapsedTime;
        }
        return cost;
    }
}