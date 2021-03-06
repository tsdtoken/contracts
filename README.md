# ReadME for Transcendence ICO!

The dApp project contains two independent yet related aspects to the successful ICO. The dApp itself is a web interface we use to connect directly to the blockchain and the targeted smart contract using Web3/portis or any Ethereum wallet enabled browser.

We also have the 4 independent contracts that will be used for **4 phases** of the the project

- The **Private Sale Contract** which will host a set of rules for the private sale buyers.
> Standard ERC20 contract with a buy in asset freeze of 9 Months from main ICO close.
	
- The **Pre Sale Contract** which will host a set of rules for the private sale buyers.
> Standard ERC20 contract with a buy in asset freeze of 12 Months from main ICO close.
	
- The **Main Sale Contract** which will host a set of rules for the private sale buyers.
> Time lockouts
> Refunds
> Trigger transfer methods in the main contract

- The **Main TSD Contract** which will host a set of rules for the private sale buyers.
> Standard ERC20 contract with rules regarding whitelisting.
> Time lockouts
> Refunds
> Transfer of ownership
> Burnable tokens
	
- The **Subsequent Sale Contract** which will host a set of rules for the private sale buyers.
> Standard ERC20 contract with the option to toggle the ability to accept Eth.
> Raise the token number in the main ICO
> Distribute tokens to subsequent purchases


# Contracts

A further discussion into the inspirations and rules of the contracts used for different stages of the ICO

## The Base Line Contract
-  It is at minimum an ERC-20 Compliant Smart Contract
- Safemath is used throughout all contracts to prevent any mathematical edge case errors
- Tokens are offered with 18 decimal places
- Initial token distribution supply which can be mutated by the owners of the smart contract, through the use of a Subsequent Supply Contract
- Pre-allocation of tokens to accounts nominated by Maoneng
-  Whitelisting (i.e only whitelisted token users are allowed to transfer their tokens, this whitelisting is dependent upon which token period they participated in - private/pre or mainsale ICO)
-  Ability to exchange Ether for pre-allocated tokens
-  Automatically transfer ETH sent to smart contract to wallet nominated by Maoneng(this ETH is real money i.e fiat converted ETH)
-  Restrictions based on start and end dates as well as total sale value
- Tokens can only be traded once the ICO has come to a conclusion

## Foundation Contracts
Strong programming principles emulate abstraction and DRY (Don't Repeat Yourself) code. Using the extensibility ability of solidity, the Foundation contracts act as a storage hub for logic that is either repeated amongst several contracts or holds seperate context and functionality from the crowd sale or ERC20 contract.

*Ownable Contract*

Open Zeppelin inspired Ownable contract that:

- Sets owner
- has a transferOwnership function
- has a renounceOwnership function
- has an onlyOwner modifier
---
*SafeMath*

Safemath library is used across all contracts for all and any mathematical functions. Since unsigned integers are used in the contract code, overflow of digits is a possible issue, Safemath adds protective guards to prevent and overflows.
Overflow example:
5-9 = 4 (instead of -4)

---
*SafeMath*

A library used for comparison checks between integers

*BaseToken*
BaseToken is Open Zeppelin inspired and consists of all the required ERC20 standard functions and events, this contract is used in the main TSD contract

---
*BaseCrowdsaleContract*
The BaseCrowdsaleContract holds abstracted logic from the multiple crowdsale contracts. The purpose of this contract is to act as a singleton hub hosting consistent sale logic, minimising maintenance overheads.

- Checks CurrentTime
- has balanceOf function
- ability to *createWhiteListedMapping* 
- ability to *removeFromWhitelist*
- ability to *changeOracleAddress*
- ability to *updateTheExchangeRate*
- ability to *setMainContractAddress* via a TSD interface
- ability to set *startTime* and *endTime*
- ability to call *safeTransfer* for FIAT payment transactions
- an *onlyRestricted* modifier for owner and oracleAddress

Functions available:

- `balanceOf`
> Returns the balance of an address
- `createWhiteListedMapping✓`
> Called externally to create whitelist for sale. Only whitelisted addresses can participate in the ico.
- `removeFromWhitelist✓`
> Enables restricted wallet to remove someone from the whitelist mapping
- `changeOracleAddress✓`
> Changes the oracle address which is used to update the ethExchangeRate
- `updateTheExchangeRate`
> This is called when the contract is constructed and by the oracle to update the rate periodically, this updates the ethToUSD exchange rate, the USD is calculated and maintained in cents
- `setMainContractAddress✓`
> Sets the main contract address reference, this instance is used during distribution of tokens

- `setStartTime✓ & setEndTime✓`
> Custom sets the start and end time
- `safeTransferFrom✓`
> Is used to transfer tokens manually primarily for FIAT buyers. Adds the buyer to the icoParticipants array - to ensure they're accommodated for when distributing tokens.
---
*SecondaryCrowdsaleContract*
The SecondaryCrowdsaleContract contains methods used in the PRE and PRIVATE contracts, this contract holds further logic abstraction for these two contracts.

- ability to *burnRemainingTokens*
- ability to *distributeTokens* to the main TSD contract
- ability to *setDistributionWallet*

- `burnRemainingTokens✓`
> Burns the remaining tokens and updates the supply, a safety check is placed to ensure that its only called after the end time has concluded.
- `distributeTokens`
> This can only be called by the owner on or after the token release date.
> This will be a two step process.
>  This function will be called by the pvtSaleTokenWallet
>  This wallet will need to be approved in the main contract to make these distributions


## Private Sale Token Contract

The first of three token sales organised by Transcendence. This round offers the highest level of discount for the token. The discount is not in perspective of reduced price for a unit token but the offering of more tokens for the same price.

> Total supply of 62.5 Million tokens will be offered and reserved in this round

> The Token follows all ERC20 principles stated in the Base Line Contract

> Only people who have whitelisted themselves with their ETH wallet addresses can participate in the token sale

> Token value is intrinsically 50 cents but offered at 30% discount (0.35 USD)

>  If someone sends more ETH than tokens available, the rest of the ETH is refunded, and the remaining tokens are allocated

Address  | Bool
------------- | -------------
xya123hi  | true
iniof232FN231  | true

The address participating in the Private round is cross checked in the balances above before accepting ETH from it.

Upon initiation, the `exchange rate`,  `start time`, `end time` and `token release date` are passed in the constructor function. When invoked, the allocated supply is transferred from the contract to the `owner's wallet`. I.e the wallet that deployed the contract.

The Private Token contract inherits from the `SecondaryCrowdsaleContract` automatically giving it access to all the methods defined in *SecondaryCrowdsaleContract* as well as *BaseCrowdsaleContract*

> Considering whitelisted addresses will be from our DB, and we'll sync it with the Private contract `createWhiteListedMapping✓` is used to populate the above mapping. An oracle has been scripted for this which will automatically execute the mapping from our database.

>  `buyTokens` acts as the fallback function and is used to allow ETH deposits. A consistent if **if-else** statement exists to confirm if the total ETH sent does not equate to more than the tokens available, and if so, **refund** the remaining ETH back to the sender.

>  All unsold tokens can be burn with `burnRemainingTokensAfterClose✓` which confirms the close of the Private ICO round before burning them.

> We keep track of the total ETH raised, to help with a easy infographic in the website

> `distrubuteTokens✓` uses instance access to the main contract to transfer tokens from the pvtSaleTokenWallet to the respective ICO participants.

> Transfer and TransferFrom in the main TSD contract are wrapped with modifications to prevent the use of them until token release date has reached.


- `buyTokens`
> Is called through a fallback function which is payable to accept ether. It calculates the token amount, ensures the validations such as time range, minimum purchase amount, and whitelisted status of the buyer. If a buyer sends more ether than the total token amount, the remainder ETH is refunded to the buyer.


## Pre-Sale Token Contract

The second of three token sales organised by Transcendence. This round offers the second highest level of discount for the token. The discount is not in perspective of reduced price for a unit token but the offering of more tokens for the same price.

> Total supply of 100 Million tokens will be offered and reserved in this round

> The token is not ERC20 compliant as it doesn't contain a fair few of the methods needed to reach compliance.

> Only people who have whitelisted themselves with their ETH wallet addresses can participate in the token sale

> Token value is intrinsically 50 cents but offered at 20% discount (0.40 USD)

Address  | Bool
------------- | -------------
xya123hi  | true
iniof232FN231  | true

The address participating in the Presale round is cross checked in the balances above before accepting ETH from it.

Considering whitelisted addresses will be from our DB, and we'll sync it with the Private contract `createWhiteListedMapping✓` is used to populate the above mapping.

`buyTokens` acts as the fallback function and is used to allow ETH deposits. A consistent if **if-else** statement exists to confirm if the total ETH sent does not equate to more than the tokens available, and if so, **refund** the remaining ETH back to the sender. The tokens are sold in tranches, where when remainder tokens traverse between tranches, ETH gains power in reference to TSD. Going with a nominal rate of 50 cents, the tranches go with 20%, 16%, 12% and 7.5%.

All unsold tokens can be burn with `burnRemainingTokensAfterClose✓` which confirms the close of the Presale ICO round before burning them.

We keep track of the total ETH raised, to help with a easy infographic in the website

`distrubuteTokens✓` uses instance access to the main contract to transfer tokens from the pvtSaleTokenWallet to the respective ICO participants.

The Pre Token contract inherits from the `SecondaryCrowdsaleContract` automatically giving it access to all the methods defined in *SecondaryCrowdsaleContract* as well as *BaseCrowdsaleContract*

> Transfer and TransferFrom are wrapped with modifications in the main TSD contract to prevent the use of them until token release date has reached.

- `tokenToEth`
> Usage:
>  Pass in the amount of tokens and the discount rate.
>   If no discount is required pass in 100 as the rate value.
- `ethToToken`
> Usage:
>Pass in the amount of eth and the discount rate.
> If no discount is required pass in 100 as the rate value.
>  This wallet will need to be approved in the main contract to make these distributions
- `calculateTotalRemainingTokenCost`
> Calculates the cost of all the remaining tokens that can be purchased based on the diluting power of the eth in respect to the TSD that can be bought.
 - `calculateTokenAmountWithDiscounts`
> Calculates the number tokens that can be purchased based on the diluting power of the eth in respect to the TSD that can be bought.

## Main token sale Contract (Crowdsale Contract)
The main crowdsale acts as a pure proxy contract to the main TSD contract. It inherits from the *BaseCrowdsaleContract* giving it all the base crowdsale abilities. Custom to itself is the buyTokens method.

Prior to kicking off the crowdsale, the fundsWallet in the main TSD contract, needs to approve the crowdsale contract to transfer tokens on its behalf, as the crowdsale acts as an interlay between the main TSD contract and the buyer.

The crowdsale contract makes use of the *safeTransferFrom* method in the main TSD contract, since the *transferFrom* methods are blocked by the *canTrade* boolean up until the ICO is finished and users can actually trade.

Functions available:

- `buyTokens`
> Is called through a fallback function which is payable to accept ether. It calculates the token amount, ensures the validations such as time range, minimum purchase amount, and whitelisted status of the buyer. If a buyer sends more ether than the total token amount, the remainder ETH is refunded to the buyer.

## Main TSD Contract

This is the contract that will, in conclusion, hold **all** wallet addresses that own TSD coin. This is the contract where no bonus will be offered during sale. The length of the ICO will be subjective to which of the following milestones are achieved first:

> End of sale date

> Total supply of TSD is 250M tokens
- 62.5M is reserved for the private sale
- 100M is reserved for the pre sale
- 37.5M is reserved for the main sale
- 20M is reserved for the founders and advisors
- 17.5M is reserved for the bounty and allocation incentives
- 7.5M is reserved for the liquidity program
- 5M is reserved for project implememtation providers

>Token depletion (all tokens sold out)

> Tokens are sold at $0.50c

Upon contract initialisation:
- The total supply is allocated to the funds wallet which is the owner wallet i.e the wallet used to deploy the contract
- Start and End dates are decided (these can be mutated)
- Exchange rate is decided (this can be changed)

Once the contract is launched, the `contractInitialAllocation✓` method is to be called immediately.  When this happens:

- Private and Presale supply is subtracted from the total supply to prevent over sell
- Tokens are transferred to the respective private and presale wallets
- Events are emitted
- Exchange rate is set based on the ethExchangeRate passed in to the constructor method.

Fallback payable function is used to absorb ETH and reward senders with TSD tokens based on the assigned exchange rate.

Similar refund logic to the private and pre token sale contracts is implemented here.

No tokens purchased can be traded until the ICO is closed, in perspective to the endTime, not the depletion of tokens.

The TSD contract inherits from the BaseToken, giving it the core background of an ERC20 base standard contract, as well as the Ownable contract..

Functions available:
- `contractInitialAllocation✓`
>Transfer all of the allocations. The inherited transfer method from the BaseToken, emits Transfer events and subtracts/adds respective amounts to respective accounts. Some wallets have tokens immediately allocated to them whilst others are given an escrowAllocation, i.e the supply amount it reduced, to accomodate for this allocation, however the target wallets cannot receive their tokens up until their respective escrowed time.
- `escrowAccountAllocation`
> Creates a struct containing token amount and escrow period - allocates this struct to an address in the *escrowBalances* mapping used as a reference in *withdrawFromEscrow*
- `withdrawFromEscrow✓`
> Can only be called by an escrowed wallet, i.e foundersAndAdvisors, bountyCommunityIncentives or projectImplementationServices. Checks to see if the current time is past the escrow period of the calling wallet, it sets the escrow balance of that wallet to 0 and allocates that escrowed amount to the calling wallet.
- `burnRemainingTokensAfterClose✓`
> Burns the remaining tokens and updates the supply, a safety check is placed to ensure that its only called after the end time has concluded. This method can be called by the private, pre or main funds wallets only
- `transfer`
> Consists of the inherited ERC20 standard transfer method, however is decorated with the *canTrade* boolean
- `transferFrom`
> Consists of the inherited ERC20 standard transferFrom method, however is decorated with the *canTrade* boolean
- `setAuthorisedContractAddress✓`
> Sets the crowndsale contract address or airdrop / designed to be used by any one external contract. This address is used in the modifier that guards *safeTranferFrom* which is explained next
-`safeTransferFrom✓`
> Implementation of the standard ERC20 *transferFrom* inherited from *BaseToken* decorated with an *isAuthorised* modifier. The concept of this function is to be used by the main *crowdsale contract* for immediate allocation of tokens, We can't use the traditional *transferFrom* methods because those are safeguarded with the *canTrade* boolean.

- `setStartTime✓ & setEndTime✓`
> Custom sets the start and end time

# Distribution of tokens
At present the logic is assumed such that tokens from private and pre sale will be held in the respective smart contracts until said release dates have not reached, which will then allow the owners of the contracts to call the distribute function, that will assign the private or pre sale token owners their equivalent TSD tokens

# Test Driven Development
Testing is a critical part of the project, we need to have the contract be as deterministic as possible, which leads to predictable results and behaviours.

**Contract: TSD**

    ✓ has an owner
    ✓ can only call contractInitialAllocation once
    ✓ sets the owner as the fundsWallet
    ✓ sets the correct pvtSaleTokenWallet address
    ✓ sets the correct preSaleTokenWallet address
    ✓ sets the correct foundersAndAdvisors address
    ✓ sets the correct bountyCommunityIncentives address
    ✓ sets the correct liquidityProgram address
    ✓ has a valid start time, end time
    ✓ sets the start time to be Sat Sep 01 2018 00:00:00 GMT+1000 (AEST)
    ✓ sets the end time to be Mon Oct 01 2018 00:00:00 GMT+1000 (AEST)
    ✓ transfers the private sale token allocation to pvtSaleTokenWallet
    ✓ transfers the pre sale token allocation to preSaleTokenWallet
    ✓ transfers the founders and advisors token allocation to foundersAndAdvisorsAllocation wallet
    ✓ transfers the bounty token allocation to bountyCommunityIncentives wallet
    ✓ transfers the liquidity program token allocation to pvtSaleTokenWallet
    ✓ funds wallet has 253 million tokens available for public sale
    ✓ can tell you if an address is whitelisted
    ✓ creates a mapping of all whitelisted addresses (44ms)
    ✓ sets the exchange rate upon initialization
    ✓ can change the exchange rate if called by the owner only (53ms)
    ✓ cannot change exchange rate from an address that isn't the owner
    ✓ refuses a sale before the public sale's start time
    ✓ refuses a sale 1 second before the private sale's start time (59ms)
    ✓ accepts ether at the exact moment the sale opens (115ms)
    ✓ accepts ether one second before close (100ms)
    ✓ rejects a transaction that is less than the minimum buy of 1 ether (125ms)
    ✓ transfers the ether to the funds wallet (287ms)
    ✓ sells the last remaining ether if less than minimum buy, returns unspent ether to the buyer, closes ICO (786ms)
    ✓ can burn any remaining tokens in the funds wallet (95ms)
    ✓ disallows a call to burn tokens from not the owner (57ms)
    ✓ the owner can set the address of the subsequent contract (113ms)
    ✓ a non owner cannot set the address of the subsequent contract (65ms)
    ✓ the owner can change the start date (39ms)
    ✓ the owner can change the end date (39ms)
    ✓ owner cannot call #increaseTotalSupplyAndAllocateTokens (79ms)
    ✓ owner cannot call #increaseEthRaisedBySubsequentSale (70ms)

 **Contract: PRETSD**
 
    ✓ has an owner
    ✓ designates the owner as the preFundsWallet
    ✓ has a valid start time, end time and token release time
    ✓ sets the start time to be Wed Aug 01 2018 00:00:00 GMT+1000 (AEST)
    ✓ sets the end time to be Wed Aug 22 2018 00:00:00 GMT+1000 (AEST)
    ✓ sets the token release time to be Thu Aug 01 2019 00:00:00 GMT+1000 (AEST)
    ✓ transfers total supply of tokens (165 million) to the pre funds wallet
    ✓ sets the exchange rate upon initialization
    ✓ can change the exchange rate if called by the owner only (52ms)
    ✓ cannot change exchange rate from an address that isn't the owner
    ✓ refuses a sale before the private sale's start time
    ✓ refuses a sale 1 second before the private sale's start time (48ms)
    ✓ accepts ether at the exact moment the sale opens (95ms)
    ✓ transfer the ether to the funds wallet (258ms)
    ✓ rejects ether from an address that isn't whitelisted (55ms)
    ✓ rejects a transaction that is less than the minimum buy of 5,000.00 USD (50ms)
    ✓ sells the required tokens based on the remaining tokens in the tranches (430ms)
    ✓ sells the last remaining ether if less than minimum buy, returns unspent ether to the buyer, closes ICO (630ms)
    ✓ disallows a call to burn tokens from not the owner (59ms)
    ✓ can set a reference to the main token contract on from owner (187ms)
    ✓ distributes private token balances into the main contract, transfers any remaining to main funds wallet token balance (530ms)
    ✓ the owner can change the start date
    ✓ the owner can change the end date

  **Contract: PVTSD**
  
    ✓ has an owner
    ✓ designates the owner as the pvtFundsWallet
    ✓ has a valid start time, end time and token release time
    ✓ sets the start time to be Fri Jun 15 2018 00:00:00 GMT+1000 (AEST)
    ✓ sets the end time to be Sun Jul 15 2018 00:00:00 GMT+1000 (AEST)
    ✓ sets the release date to be Mon Apr 15 2019 00:00:00 GMT+1000 (AEST)
    ✓ transfers total supply of tokens (82.5 million) to the private funds wallet
    ✓ can tell you if an address is whitelisted
    ✓ creates a mapping of all whitelisted addresses (41ms)
    ✓ sets the exchange rate upon initialization
    ✓ can change the exchange rate if called by the owner only (53ms)
    ✓ cannot change exchange rate from an address that isn't the owner
    ✓ refuses a sale before the private sale's start time
    ✓ refuses a sale 1 second before the private sale's start time (52ms)
    ✓ accepts ether at the exact moment the sale opens (126ms)
    ✓ applies a 30% discount on token sales (109ms)
    ✓ keeps a reference of all buyers address in the icoParticipants array (130ms)
    ✓ transfers the ether to the funds wallet (277ms)
    ✓ rejects ether from an address that isn't whitelisted (56ms)
    ✓ rejects a transaction that is less than the minimum buy of 50,000.00 USD (192ms)
    ✓ sells the last remaining ether if less than minimum buy, returns unspent ether to the buyer, closes ICO (541ms)
    ✓ can burn any remaining tokens in the funds wallet (91ms)
    ✓ disallows a call to burn tokens from not the owner (49ms)
    ✓ can set a reference to the main token contract on from owner (171ms)
    ✓ distributes private token balances into the main contract (572ms)
    ✓ the owner can change the start date
    ✓ the owner can change the end date
