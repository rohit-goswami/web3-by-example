pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/stdlib.sol";


import "src/Flash Loan/FlashLoan.sol";

contract User{}

contract TestToken is ERC20('Token Test', 'TEST', 18) {
    function mintTo(address to, uint256 amount) public payable {
        _mint(to,amount);
    }
}

contract TestReceiver is FlashBorrower, Test {
    bytes32 internal testData;
    bool internal shouldRepay = true;
    bool internal shouldPayFees = true;

    function setTestData(bytes calldata data) public payable {
        testData = bytes32(data);
    }

    function setRepay(bool _shouldRepay) public payable {
        shouldRepay = _shouldRepay;
    }

    function setRespectFees(bool _shouldPayFees) public payable {
        shouldPayFees = _shouldPayFees;
    }

    function onFlashLoan(
        ERC20 token,
        uint256 amount,
        bytes calldata data
    ) external {
        assertEq(testData, bytes32(data));

        if(!shouldRepay) return;
        token.transfer(msg.sender, amount);
        if(!shouldPayFees) return;

        uint256 owedFees = FlashLoan(msg.sender).getFee(token, amount);
        TestToken(address(token)).mintTo(msg.sender, owedFees);

    }
}


contract FlashLoanTest is Test {
    User internal user;
    TestToken internal token;
    TestReceiver internal receiver;
    FlashLoan internal flashLoan;


    event FeeUpdated(ERC20 indexed token, uint256 fee);
    event Withdraw(ERC20 indexed token, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event FlashLoaned(FlashBorrower indexed receiver, ERC20 indexed token, uint256 amount);


    function setUp() public {
        user = new User();
        token = new TestToken();
        receiver = new TestReceiver();
        flashLoan = new FlashLoan();
    }


    function testCanFlashLoan() public {
        token.mintTo(address(flashLoan), 100 ether);

        vm.expectEmit(true, true, false, true);
        emit FlashLoaned(receiver, token, 100 ether);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(flashLoan), address(receiver), 100 ether);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(receiver), address(flashLoan), 100 ether);

        flashLoan.execute(receiver, token, 100 ether, '');

        assertEq(token.balanceOf(address(flashLoan)), 100 ether);
    }

    function testDataIsForwarded() public {
        receiver.setTestData('forwarded data');
        token.mintTo(address(flashLoan), 100 ether);

        flashLoan.execute(receiver, token, 100 ether, 'forwarded data');
    }

    function testCanFlashLoanWithFees() public {
        token.mintTo(address(flashLoan), 100 ether);

        // set 10% fee
        flashLoan.setFees(token, 10_000);
        flashLoan.execute(receiver, token, 100 ether, '');

        assertEq(token.balanceOf(address(flashLoan)), 110 ether);
        
    }


    function testCannotFlashLoanIfNotEnoughBalance() public {
        token.mintTo(address(flashLoan), 1 ether);
        vm.expertRevert(stdError.airthmeticError);
        flashLoan.execute(receiver, token, 2 ether, '');
        assertEq(token.balanceOF(address(flashLoan)), 1 ether);
    }

    function testFlashloanRevertsIfNotRepaid() public {
        receiver.setRepay(false);
        token.mint(address(flashLoan), 100 ether);
        vm.expectRevert(abi.encodeWithSignature('TokensNotReturned()'));
        flashLoan.execute(receiver, token, 100 ether, '');
        assertEq(token.balanceOf(address(flashLoan)), 100 ether);
    }

    function testFlashLoanRevertsIfNotFeeNotPaid() public {
        receiver.setRespectFees(false);
        flashLoan.setFees(token, 10_000);

        token.mintTo(address(flashLoan), 100 ether);

        vm.expectRevert(abi.encodeWithSignature('TokensNotReturned()'));
        flashLoan.execute(receiver, token, 100 ether, '' );
        assertEq(tokenbalanceOf(address(flashLoan)), 100 ether);
    }

    
}