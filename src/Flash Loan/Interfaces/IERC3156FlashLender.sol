// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;


import "./IERC3156FlashBorrower.sol";

/**
 * @dev The lender interface must be implemented by Flash Loan services wanting to provide a flash loan.
 */
interface IERC3156FlashLender {
    /**
     * @dev The amount of currency available to get as a loan.
     * @param token The loan currency.
     * @return The amount of 'token' that can be borrowed.
     */
    function maxFlashLoan(address token) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of 'token' to be charged for the loan, on top of the returned principal.
     */
    function flashFee(address token, uint256 amount) external view returns (uint256);

    /**
     * @dev Initiate a flash loan
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data stucture, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns(bool);

    
}