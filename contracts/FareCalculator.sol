// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract FareCalculator {
    function evaluate(
        uint256 start_,
        uint256 stop_,
        uint256 occupancy_,
        address userAddress_,
        address contractAddress_
    ) public virtual returns (uint256);
}

contract Fare1 is FareCalculator {
    function evaluate(
        uint256 start_,
        uint256 stop_,
        uint256, /*occupancy_*/
        address, /*userAddress_*/
        address /*contractAddress_*/
    ) public pure override returns (uint256) {
        return stop_ - start_;
    }
}