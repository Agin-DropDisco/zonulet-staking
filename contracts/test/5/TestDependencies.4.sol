//SPDX-License-Identifier: GPL-3.0

pragma solidity =0.5.16;

import "zonulet-core/contracts/ZonuDexFactory.sol";
import "zonulet-core/contracts/ZonuDexPair.sol";

contract FakeZonuletPair is ZonuDexPair {
    constructor(address _token0, address _token1) public {
        token0 = _token0;
        token1 = _token1;
    }
}

contract FailingToken0GetterZonuletPair {
    address public token1;

    constructor(address _token1) public {
        token1 = _token1;
    }

    function token0() external pure returns (address) {
        revert("failed");
    }
}

contract FailingToken1GetterZonuletPair {
    address public token0;

    constructor(address _token0) public {
        token0 = _token0;
    }

    function token1() external pure returns (address) {
        revert("failed");
    }
}
