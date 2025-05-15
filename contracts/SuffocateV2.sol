// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1363Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC1363Upgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact security@watchmesuffocate.com
contract Suffocate is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, ERC1363Upgradeable, ERC20PermitUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address recipient, address initialOwner)
        public initializer
    {
        __ERC20_init("Suffocate", "WMS");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC1363_init();
        __ERC20Permit_init("Suffocate");
        __UUPSUpgradeable_init();

        _mint(recipient, 1000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
    }
}

contract SuffocateV2 is Suffocate {
    function version() external pure returns(string memory) {
        return "Suffocate v2";
    }

    address public fansWallet;
    address public daoWallet;
    address public liquidityWallet;
    address public marketingWallet;
    address public rewardsWallet;

    bool private _supplyDistributed;

    function distributeInitialSupply(
        address _fansWallet, // Verteilung an Fans
        address _daoWallet,
        address _liquidityWallet,
        address _marketingWallet,
        address _rewardsWallet
    ) external onlyOwner {
        require(!_supplyDistributed, "Already distributed");

        fansWallet = _fansWallet;
        daoWallet = _daoWallet;
        liquidityWallet = _liquidityWallet;
        marketingWallet = _marketingWallet;
        rewardsWallet = _rewardsWallet;

        uint256 total = totalSupply();

        _transfer(msg.sender, daoWallet, (total * 10) / 100);
        _transfer(msg.sender, fansWallet, (total * 20) / 100);
        _transfer(msg.sender, liquidityWallet, (total * 10) / 100);
        _transfer(msg.sender, marketingWallet, (total * 5) / 100);
        _transfer(msg.sender, rewardsWallet, (total * 5) / 100);

        _supplyDistributed = true;

        emit InitialSupplyDistributed();
    }
    
    event InitialSupplyDistributed();
}