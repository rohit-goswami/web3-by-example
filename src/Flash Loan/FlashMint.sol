pragma solidity 0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "./Interfaces/IERC3156FlashBorrower.sol";
import "./Interfaces/IERC3156FlashLender.sol";

/**
 * @author Rohit Goswami
 * @dev Extension for ERC20 that allows flash minting.
 */

contract FlashMinter is ERC20, IERC3156FlashLender {
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 public fee; ; // 1 == 0.1 %

    /**
     * @param fee_ The percentage of the loan 'amount' that needs to be repaid, in addition to 'amount'.
     */
    constructor (
        string memory name,
        string memory symbol,
        uint256 fee_
    ) ERC20(name, symbol) {
        fee = fee_;
    }

    /**
     * @dev The fee to be charged for a given loan
     * @param token The loan currency. Must match the address of this contract.
     * @param amount The amount of token lent.
     * @return The amount of 'token' to be charged fo the loan, on top of the returned principal.
     */

    function flashFee (
        address token,
        uint256 amount
    ) external view override returns ( uint256 ) {
        require (token == address(this), "FlashMinter: Unsupported Currency" );
        return _flashFee(token, amount);
    }

    /**
     * @dev Loan 'amount' tokens to 'receiver', and takes it back plus a 'flashFee' after the ERC3156 callback.
     * @param receiver The contract receiving the tokens, needs to implement the 'onFlashLoan(address user, uint256 amount, uint25 fee, bytes calldata)' interface.
     * @param token The loan currency. Must match the address of this contract.
     * @param amount The amount of tokens lent.
     * @param data A data parameter to be passed on to the 'receiver' for any custom use.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        require (token == address(this), "FlashMinter: Unsupported currency");
        uint256 fee = _flashFee(token, amount);
        _mint(address(receiver), amount);
        require(receiver.onFlashLoan(msg.sender, token, amount, fee, data) == CALLBACK_SUCCESS, "FlashMinter: Callback failed");
        uint256 _allowance = allowance(address(receiver), address(this));
        require(_allowance >= (amount+fee), "FlashMinter: Repay not approved");
        _approve( address(receiver), address(this), _allowance - (amount+fee));
        return true;
    }

    /**
     * @dev The feee to be charged for a given loan. Internal function with no checks.
     * @param token The laon currency.
     * @param amount The amount of tokens lent.
     * @return The amount of 'token' to be charged for the loan, on top of the returned principal.
     */
    function _flashFee(
        address token,
        uint256 amount
    ) internal view returns (uint256) {
        return amount * fee / 10000;
    }
}

