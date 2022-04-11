// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import {BallotStorage} from "./BallotStorage.sol";
import {BallotLib} from "./BallotLib.sol";
import {OwnableUpgradeable}     from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable}          from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title 委托投票
contract Ballot is BallotStorage, Initializable, OwnableUpgradeable {

    /// @notice OZ upgradeable initialization
    constructor(
        string[] memory proposalNames
    ) {
        initialize(proposalNames);
    }

    function initialize(string[] memory proposalNames) internal initializer {
        // make sure contract has not already been initialized
        require(proposals.length == 0, "Already Initialized");
        voters[msg.sender].weight = 1;
        for (uint i = 0; i < proposalNames.length; i++) {
            //对于提供的每个提案名称，
            //创建一个新的 Proposal 对象并把它添加到数组的末尾。
            string memory proposalName = proposalNames[i];
            proposals.push(BallotLib.Proposal({
            // `Proposal({...})` 创建一个临时 Proposal 对象，
            // `proposals.push(...)` 将其添加到 `proposals` 的末尾
                name: proposalName,
                voteCount: 0
            }));
        }
        __Ownable_init();
    }
    
    // 授权 `voter` 对这个（投票）表决进行投票
    // 只有 `chaiman` 可以调用该函数。
    function giveRightToVoter(address _voter) external virtual onlyOwner {
        // 若 `require` 的第一个参数的计算结果为 `false`，
        // 则终止执行，撤销所有对状态和以太币余额的改动。
        // 在旧版的 EVM 中这曾经会消耗所有 gas，但现在不会了。
        // 使用 require 来检查函数是否被正确地调用，是一个好习惯。
        // 你也可以在 require 的第二个参数中提供一个对错误情况的解释。
        BallotLib.Voter storage voter = voters[_voter];
        require(
            voter.voted,
            "The voter already voted"
        );
        require(voter.weight == 0, "Already given the right");
        voter.weight = 1;
    }

    /// 把你的投票委托到投票者 `to`。
    function delegate(address to) public {
        require(to != _msgSender(), "Self-delegation is disallowed.");


        BallotLib.Voter storage sendersVoter = voters[_msgSender()];
        require(!sendersVoter.voted, "You already voted.");

        // 委托是可以传递的，只要被委托者 `to` 也设置了委托。
        // 一般来说，这种循环委托是危险的。因为，如果传递的链条太长，
        // 则可能需消耗的gas要多于区块中剩余的（大于区块设置的gasLimit），
        // 这种情况下，委托不会被执行。
        // 而在另一些情况下，如果形成闭环，则会让合约完全卡住。
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            
            // 不允许闭环委托
            require(to != msg.sender, "Found loop in delegation.");
        }

        // `sendersVoter` 是一个引用, 相当于对 `voters[msg.sender].voted` 进行修改
        sendersVoter.voted = true;
        sendersVoter.delegate = to;
        BallotLib.Voter storage delegator = voters[to];
        if (delegator.voted) {
            // 若被委托者已经投过票了，直接增加得票数
            proposals[delegator.voteIndex].voteCount += sendersVoter.weight;
        } else {
            delegator.weight += sendersVoter.weight;
        }
    }

        /// 把你的票(包括委托给你的票)，
    /// 投给提案 `proposals[proposal].name`.
    function vote(uint _proposalIndex) public {
        BallotLib.Voter storage sender = voters[_msgSender()];
        require(_proposalIndex < proposals.length);
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.voteIndex = _proposalIndex;

        // 如果 `proposal` 超过了数组的范围，则会自动抛出异常，并恢复所有的改动
        proposals[_proposalIndex].voteCount += sender.weight;
    }

       /// @dev 结合之前所有的投票，计算出最终胜出的提案
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

        // 调用 winningProposal() 函数以获取提案数组中获胜者的索引，并以此返回获胜者的名称
    function winnerName() public view
            returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }


}
