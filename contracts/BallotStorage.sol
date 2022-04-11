// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.4;

import "./BallotLib.sol";

contract BallotStorage {
    
    // 这声明了一个状态变量，为每个可能的地址存储一个 `Voter`。
    mapping(address => BallotLib.Voter) public voters;

    // 一个 `Proposal` 结构类型的动态数组
    BallotLib.Proposal[] public proposals;

}