## Flash Loans

`Idea was to enable a non-collateral borrowing service.`

<img width="319" alt="image" src="https://user-images.githubusercontent.com/15854015/217230000-0abe89e4-a712-48d4-8e53-f30f7fe9bc32.png">

### General Workflow 

Two main entities : ***Flash Loan Providers*** & ***Users***.

To interact with Flash Loan Providers, Users required to develop a smart contract. A user’s contract usually includes three parts: 
1) borrowing the loan(s) from Flash Loan providers, 
2) interacting with other smart contracts, and 
3) returning the loan(s).

Let's break down Flash Loan transaction into 5 steps:
1. *Flash Loan Providers* transfers requested assets to the *Users*.
2. Invoke *Users's* pre-designed operations.
3. Users will use borrowed assets to execute other operations.
4. After completion of execution, *Users* hae to returns the borrowed amount with or withour the extra fee carged by providers.
5. *Flash Loan Providers* will check their balance and in case of insufficient funds return they can revert the whole transaction.

``You see there are 5 steps invloved but due to atomicity of trasaction all those steps are finished in single transaction.😱``

## Flash Loan Providers

### **Aave**

Aave provides a native function ```flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params)```  in **[LendingPool](https://github.com/aave/aave-protocol/blob/4b4545fb583fd4f400507b10f3c3114f45b8a037/contracts/lendingpool/LendingPool.sol#L843)** contract to trigger flash loan. Aave also charges some fee for using flash loan service. 


