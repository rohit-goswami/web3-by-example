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

Aave provides a native function in **[LendingPool](https://github.com/aave/aave-protocol/blob/4b4545fb583fd4f400507b10f3c3114f45b8a037/contracts/lendingpool/LendingPool.sol#L843)** contract to trigger flash loan. Aave also charges some fee for using flash loan service. 

```solidity= 
flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params)
```
**Prepare Flash Loan contract with Aave**

Users Develop Smart Contract consist of one execution function and one entry-point function. Here execution function will contains users' designed operation for the loaned assets. Execution function has to be formed based on ```executeOperation``` [function](https://github.com/aave/aave-protocol/blob/4b4545fb583fd4f400507b10f3c3114f45b8a037/contracts/flashloan/interfaces/IFlashLoanReceiver.sol#L11) in Base contract. In entry point function user need to prepare the function ```flashLoan``` to request a loan. Then, follow up with the function ```executeOperation``` to run the designed logic. Lastly return the loaned assets with [function](https://github.com/aave/aave-protocol/blob/4b4545fb583fd4f400507b10f3c3114f45b8a037/contracts/flashloan/base/FlashLoanReceiverBase.sol#L24) ```transferFundBackToPoolInternal ```. If Aave discovers unbalanced vault state then it will revert the entire transaction. After you code your smart contract, deploy it to the chain and use Flash Loan service from Aave by invoking the entry-point function.

👉 **[Aave v3 Flash Loan](https://docs.aave.com/developers/guides/flash-loans)** 

**Identifying flash loan transaction from Aave**

Aave emits an event FlashLoan whenever the fucntion FlashLoan is executed, therefore we can easily identify the flash loan tx. from Aave.

### **dYdX**

There is no native Flash Loan Feature available in dYdX. However, dYdX's contract Operation has a [function](https://github.com/dydxprotocol/solo/blob/0412e9457c113f663117fa6ce1048a06839ba388/contracts/protocol/Operation.sol#L54) called ```operate``` that enables to bring a series of operations into one transaction to achieve Flash Loan for users. Best thing, dYdX does not charge any fee for invoking the function ```operate```.

**Prepare Flash Loan contract with dYdX**

Similar to Aave, we need to code a smart contract containing one execution function, which contains users' operating logic on the loaned assets, and one entry point function.  In the entry-point function, users first need to sequentially organize a list of provided (by dYdX) actions: withdraw, callFunction and deposit.








