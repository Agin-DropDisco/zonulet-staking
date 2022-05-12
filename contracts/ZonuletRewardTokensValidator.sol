// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRewardTokensValidator.sol";
import "./interfaces/IZonuletTokenRegistry.sol";

contract DefaultRewardTokensValidator is IRewardTokensValidator, Ownable {
    IZonuletTokenRegistry public zonuletTokenRegistry;
    uint256 public zonuletTokenRegistryListId;

    constructor(address _zonuletTokenRegistryAddress, uint256 _zonuletTokenRegistryListId)
    {
        require(
            _zonuletTokenRegistryAddress != address(0),
            "DefaultRewardTokensValidator: 0-address token registry address"
        );
        require(
            _zonuletTokenRegistryListId > 0,
            "DefaultRewardTokensValidator: invalid token list id"
        );
        zonuletTokenRegistry = IZonuletTokenRegistry(_zonuletTokenRegistryAddress);
        zonuletTokenRegistryListId = _zonuletTokenRegistryListId;
    }

    function setZonuletTokenRegistry(address _zonuletTokenRegistryAddress)
        external
        onlyOwner
    {
        require(
            _zonuletTokenRegistryAddress != address(0),
            "DefaultRewardTokensValidator: 0-address token registry address"
        );
        zonuletTokenRegistry = IZonuletTokenRegistry(_zonuletTokenRegistryAddress);
    }

    function setZonuletTokenRegistryListId(uint256 _zonuletTokenRegistryListId)
        external
        onlyOwner
    {
        require(
            _zonuletTokenRegistryListId > 0,
            "DefaultRewardTokensValidator: invalid token list id"
        );
        zonuletTokenRegistryListId = _zonuletTokenRegistryListId;
    }

    function validateTokens(address[] calldata _rewardTokens)
        external
        view
        override
    {
        require(
            _rewardTokens.length > 0,
            "DefaultRewardTokensValidator: 0-length reward tokens array"
        );
        for (uint256 _i = 0; _i < _rewardTokens.length; _i++) {
            address _rewardToken = _rewardTokens[_i];
            require(
                _rewardToken != address(0),
                "DefaultRewardTokensValidator: 0-address reward token"
            );
            require(
                zonuletTokenRegistry.isTokenActive(
                    zonuletTokenRegistryListId,
                    _rewardToken
                ),
                "DefaultRewardTokensValidator: invalid reward token"
            );
        }
    }
}
