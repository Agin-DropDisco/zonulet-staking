// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "./interfaces/IStakableTokenValidator.sol";
import "./interfaces/IZonuletTokenRegistry.sol";
import "zonulet-core/contracts/interfaces/IZonuDexPair.sol";
import "zonulet-core/contracts/interfaces/IZonuDexFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DefaultStakableTokenValidator is IStakableTokenValidator, Ownable {
    IZonuletTokenRegistry public zonuletTokenRegistry;
    uint256 public zonuletTokenRegistryListId;
    IZonuDexFactory public zonuletFactory;

    constructor(
        address _zonuletTokenRegistryAddress,
        uint256 _zonuletTokenRegistryListId,
        address _zonuletFactoryAddress
    ) {
        require(
            _zonuletTokenRegistryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address token registry address"
        );
        require(
            _zonuletTokenRegistryListId > 0,
            "DefaultStakableTokenValidator: invalid token list id"
        );
        require(
            _zonuletFactoryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address factory address"
        );
        zonuletTokenRegistry = IZonuletTokenRegistry(_zonuletTokenRegistryAddress);
        zonuletTokenRegistryListId = _zonuletTokenRegistryListId;
        zonuletFactory = IZonuDexFactory(_zonuletFactoryAddress);
    }

    function setZonuletTokenRegistry(address _zonuletTokenRegistryAddress)
        external
        onlyOwner
    {
        require(
            _zonuletTokenRegistryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address token registry address"
        );
        zonuletTokenRegistry = IZonuletTokenRegistry(_zonuletTokenRegistryAddress);
    }

    function setZonuletTokenRegistryListId(uint256 _zonuletTokenRegistryListId)
        external
        onlyOwner
    {
        require(
            _zonuletTokenRegistryListId > 0,
            "DefaultStakableTokenValidator: invalid token list id"
        );
        zonuletTokenRegistryListId = _zonuletTokenRegistryListId;
    }

    function setZonuletFactory(address _zonuletFactoryAddress)
        external
        onlyOwner
    {
        require(
            _zonuletFactoryAddress != address(0),
            "DefaultStakableTokenValidator: 0-address factory address"
        );
        zonuletFactory = IZonuDexFactory(_zonuletFactoryAddress);
    }

    function validateToken(address _stakableTokenAddress)
        external
        view
        override
    {
        require(
            _stakableTokenAddress != address(0),
            "DefaultStakableTokenValidator: 0-address stakable token"
        );
        IZonuDexPair _potentialZonuDexPair = IZonuDexPair(_stakableTokenAddress);
        address _token0;
        try _potentialZonuDexPair.token0() returns (address _fetchedToken0) {
            _token0 = _fetchedToken0;
        } catch {
            revert(
                "DefaultStakableTokenValidator: could not get token0 for pair"
            );
        }
        require(
            zonuletTokenRegistry.isTokenActive(zonuletTokenRegistryListId, _token0),
            "DefaultStakableTokenValidator: invalid token 0 in Zonulet pair"
        );
        address _token1;
        try _potentialZonuDexPair.token1() returns (address _fetchedToken1) {
            _token1 = _fetchedToken1;
        } catch {
            revert(
                "DefaultStakableTokenValidator: could not get token1 for pair"
            );
        }
        require(
            zonuletTokenRegistry.isTokenActive(zonuletTokenRegistryListId, _token1),
            "DefaultStakableTokenValidator: invalid token 1 in Zonulet pair"
        );
        require(
            zonuletFactory.getPair(_token0, _token1) == _stakableTokenAddress,
            "DefaultStakableTokenValidator: pair not registered in factory"
        );
    }
}
