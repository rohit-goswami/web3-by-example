//SPDX-License-Identifier: MIT 

pragma solidity 0.8.17;
/**
 * @dev The borrower interface consist of onFlashLoan callback function 
 */

interface IERC3156FlashBorrower {

    /**
     * @dev Receive a flash loan
     * @param initiator The initiator of the Loan.
     * @param token The Loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay as a fee.
     * @param data Arbitary data structure, intended to contain user-defined parameters
     * @return The keccak256 hash of "ERC3156FlashLoanBorrower.onFlashLoan".
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}