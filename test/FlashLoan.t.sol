pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "src/Flash Loan/FlashLoan.sol";

contract TestToken is ERC20('Token Test', 'TEST', 18) {
    function mintTo(address to, uint256 amount) public payable {
        _mint(to,amount);
    }


}