// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.4;

library BallotLib {
    // 这里声明了一个新的复合类型用于稍后的变量
    // 它用来表示一个选民
    struct Voter {
        uint weight; // 计票的权重
        bool voted; // 若为真，代表该人已投票
        address delegate; // 被委托人
        uint voteIndex; // 投票提案的索引
    }

    // 提案的类型
    struct Proposal {
        string name; 
        uint voteCount;
    }
}