//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

import {ERC20} from "solmate/tokens/ERC20.sol";


interface FlashBorrower {
    
    function onFlashLoan(
        ERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract FlashLoan {
    
    event FlashLoaned(FlashBorrower indexed receiver, ERC20 indexed token, uint256 amount);
    event FeeUpdated(ERC20 indexed token, uint256 fee);
    event Withdraw(ERC20 indexed token, uint256 amount);


    error Unauthorized();
    error TokenNotReturned();
    error invalidPercentage();


    address public immutable manager;

    mapping(ERC20 => uint256) public fees;

    constructor() payable {
        manager = msg.sender;
    }


    function execute(
        FlashBorrower receiver,
        ERC20 token,
        uint256 amount,
        bytes calldata data
    ) public payable {
        uint256 currentBalance = token.balanceOf(address(this));
        
        emit FlashLoaned(receiver, token, amount);

        // Do we need to check that reciever is contract or atleast it's not a zero address ? 
        token.transfer(address(receiver), amount);
        receiver.onFlashLoan(token, amount, data);

        if (currentBalance + getFee(token,amount) > token.balanceOf(address(this))) revert TokenNotReturned();
    }

    function getFee(ERC20 token, uint256 amount) public view returns (uint256) {
        if(fees[token] == 0) return 0;
        return (amount * fees[token]) / 10_000;
    }

    function setFees(ERC20 token, uint256 fee) public payable {
        if(msg.sender != manager) revert Unauthorized();
        if(fee > 10_000) revert invalidPercentage();
        emit FeeUpdated(token, fee);
        fees[token] = fee;
    }

    function withdraw(ERC20 token, uint256 amount) public payable {
        if(msg.sender != manager) revert Unauthorized();
        emit Withdraw(token, amount);
        token.transfer(msg.sender, amount);
    }
}