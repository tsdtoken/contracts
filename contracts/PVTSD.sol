pragma solidity ^0.4.23;

import "./FoundationContracts/BaseToken.sol";
import "./FoundationContracts/Ownable.sol";
import "./TSD.sol";

contract PVTSD is Ownable, BaseToken {
    using SafeMath for uint256;
    // set up access to main contract for the future distribution
    TSD dc;
    // when the connection is set to the main contract, save a reference for event purposes
    address public TSDContractAddress;
    
    string public name = "PRIVATE TSD COIN";
    string public symbol = "PVTSD";
    uint256 public decimals = 18;
    uint256 public decimalMultiplier = uint256(10) ** decimals;
    uint256 public million = 1000000 * decimalMultiplier;
    uint256 public totalSupply = 55 * million;
    // CHANGE TO 50 ETH
    uint256 public minPurchase = 1 ether;
    // 1 TSD = x ETH
    // Unit convertsions https://github.com/ethereum/web3.js/blob/0.15.0/lib/utils/utils.js#L40
    uint256 public exchangeRate;
    uint256 public totalEthRaised = 0;

    // Coordinated Universal Time (abbreviated to UTC) is the primary time standard by which the world regulates clocks and time.

    // Start time "Fri Jun 15 2018 00:00:00 GMT+1000 (AEST)"
    // new Date(1535724000000).toUTCString() => "Thu, 14 Jun 2018 14:00:00 GMT"
    uint256 public startTime = 1528984800000;
    // End time "Fri Jul 15 2018 00:00:00 GMT+1000 (AEST)"
    // new Date(1531576800000).toUTCString() => "Sat, 14 Jul 2018 14:00:00 GMT"
    uint256 public endTime = 1531576800000;
    // Token release date 9 months post end date
    // "Mon April 15 2019 00:00:00 GMT+1000 (AEST)"
    // new Date(1555250400000).toUTCString() => "Sun, 14 Apr 2019 14:00:00 GMT"
    uint256 public tokensReleaseDate = 1555250400000;

    // Wallets
    address public pvtFundsWallet;

    // Array of participants used when distributing tokens to main contract
    address[] public icoParticipants;
    
    // whitelisted addresses
    mapping (address => bool) public whiteListed;

    // ico concluded
    bool icoOpen = true;
    
    // Events
    event EthRaisedUpdated(uint256 oldEthRaisedVal, uint256 newEthRaisedVal);
    event ExhangeRateUpdated(uint256 prevExchangeRate, uint256 newExchangeRate);
    event DistributedAllBalancesToTSDContract(address _presd, address _tsd);
    event DebuggingAmounts(string nameOfValue, uint256 amount);
    
    constructor(
        uint256 _exchangeRate,
        address[] _whitelistAddresses
    ) public {
        pvtFundsWallet = owner;

        // transfer suppy to the pvtFundsWallet
        balances[pvtFundsWallet] = totalSupply;
        emit Transfer(0x0, pvtFundsWallet, totalSupply);

        // set up the white listing mapping
        createWhiteListedMapping(_whitelistAddresses);

        // set up the exchangeRate
        updateTheExchangeRate(_exchangeRate);
    }

    // Contract utility functions
    
    function currentTime() public view returns (uint256) {
        return now * 1000;
    }
    
    function createWhiteListedMapping(address[] _addresses) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whiteListed[_addresses[i]] = true;
        }
    }

    // Updates the ETH => TSD exchange rate
    function updateTheExchangeRate(uint256 _newRate) public onlyOwner returns (bool) {
        uint256 currentRate = exchangeRate;
        uint256 oneSzabo = 1 szabo;
        exchangeRate = (oneSzabo).mul(_newRate);
        emit ExhangeRateUpdated(currentRate, _newRate);
        return true;
    }

    function isWhiteListed(address _address) public view returns (bool) {
        if (whiteListed[_address]) {
            return true;
        } else {
            return false;
        }
    }

    // Buy functions
    
    function() payable public {
        buyTokens();
    }
    
    function buyTokens() payable public {
        require(icoOpen);
        require(currentTime() >= startTime && currentTime() <= endTime);
        require(msg.value >= minPurchase);
        require(whiteListed[msg.sender]);

        // ETH received by spender
        uint256 ethAmount = msg.value;

        // token amount based on ETH / exchangeRate result
        // exchange rate is 1 TSD => x ETH
        // with a 40% discount attached
        uint256 discountedExchangeRate = exchangeRate.mul(60).div(100);
        // totalTokenAmount is the total tokens offered including the discount
        // Multiply with  to decimalMultiplier to get total tokens (to 18 decimal place)
        uint256 totalTokenAmount = ethAmount.div(discountedExchangeRate).mul(decimalMultiplier);

        // tokens avaialble to sell are the remaining tokens in the pvtFundsWallet
        uint256 availableTokens = balances[pvtFundsWallet];
        uint256 currentEthRaised = totalEthRaised;
        uint256 ethRefund = 0;
        uint256 additionalTokens;
        
        if (totalTokenAmount > availableTokens) {
            // additional tokens that aren't avaialble to be sold
            // tokenAmount is the tokens requested by buyer (not including the bonus)
            // availableTokens are all the tokens left in the supplying wallet i.e pvtFundsWallet
            additionalTokens = totalTokenAmount.sub(availableTokens);

            // determine the unused ether amount by seeing how many tokens were surplus
            // i.e 'availableTokens' and reverse calculating their ETH equivalent
            // divide by decimalMultiplier as additionalTokens are 10^18
            ethRefund = additionalTokens.mul(discountedExchangeRate).div(decimalMultiplier);
  
            // subtract the refund amount from the eth amount received by the tx
            ethAmount = ethAmount.sub(ethRefund);
            // make the token purchase
            // will equal to 0 after these substractions occur
            balances[pvtFundsWallet] = balances[pvtFundsWallet].sub(availableTokens);

            // add total tokens to the senders balances and Emit transfer event
            balances[msg.sender] = balances[msg.sender].add(availableTokens);
            emit Transfer(pvtFundsWallet, msg.sender, availableTokens);
            icoParticipants.push(msg.sender);
            // refund
            if (ethRefund > 0) {
                msg.sender.transfer(ethRefund);
            }
            // transfer ether to funds wallet
            pvtFundsWallet.transfer(ethAmount);
            totalEthRaised = totalEthRaised.add(ethAmount);
            emit EthRaisedUpdated(currentEthRaised, totalEthRaised);
            // close token sale as tokens are sold out
            icoOpen = false;
        } else {
            require(availableTokens >= totalTokenAmount);
            // complete transfer and emit an event
            balances[pvtFundsWallet] = balances[pvtFundsWallet].sub(totalTokenAmount);
            balances[msg.sender] = balances[msg.sender].add(totalTokenAmount);
            icoParticipants.push(msg.sender);
            
            // transfer ether to the wallet and emit and event regarding eth raised
            pvtFundsWallet.transfer(ethAmount);
            totalEthRaised = totalEthRaised.add(ethAmount);
            emit Transfer(pvtFundsWallet, msg.sender, totalTokenAmount);
            emit DebuggingAmounts("current balance", balances[pvtFundsWallet]);
            emit EthRaisedUpdated(currentEthRaised, totalEthRaised);  
        }
    }

    // After close functions

    // Create an instance of the main contract
    function setMainContractAddress(address _t) onlyOwner public {
        dc = TSD(_t);
        TSDContractAddress = _t;
    }

   // Burn any remaining tokens 
    function burnRemainingTokens() onlyOwner public returns (bool) {
        require(currentTime() >= endTime);
        if (balances[pvtFundsWallet] > 0) {
            balances[pvtFundsWallet] = 0;
        }

        return true;
    }

    // This can only be called by the owner on or after the token release date.
    // This will be a two step process.
    // This function will be called by the pvtSaleTokenWallet
    // This wallet will need to be approved in the main contract to make these distributions
    
    function distrubuteTokens() onlyOwner public {
        require(currentTime() >= tokensReleaseDate);
        address pvtSaleTokenWallet = dc.pvtSaleTokenWallet();
        address mainContractFundsWallet = dc.fundsWallet();
        for (uint8 i = 0; i < icoParticipants.length; i++) {
            dc.transferFrom(pvtSaleTokenWallet, icoParticipants[i], balances[icoParticipants[i]]);
            emit Transfer(pvtSaleTokenWallet, icoParticipants[i], balances[icoParticipants[i]]);
        }

        if (dc.balanceOf(pvtSaleTokenWallet) > 0) {
            uint256 remainingBalace = dc.balanceOf(pvtSaleTokenWallet);
            dc.transferFrom(pvtSaleTokenWallet, mainContractFundsWallet, remainingBalace);
            emit Transfer(pvtSaleTokenWallet, mainContractFundsWallet, remainingBalace);
        }
        // Event to say distribution is complete
        emit DistributedAllBalancesToTSDContract(address(this), TSDContractAddress);
    }
}