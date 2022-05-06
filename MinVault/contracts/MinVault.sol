// SPDX-License-Identifier: MIXED
// License-Identifier: MIT
pragma solidity 0.4.22;


interface IWETH {
    function deposit() external payable;

    function withdraw(uint) external;

    function transfer(address dst, uint wad) external returns (bool);

    function transferFrom(address src, address dst, uint wad) external returns (bool);
 
}

contract masterWethMim {

    mapping (address => uint) public balanceOfWETH;

    function addCollateral(IWETH _contract, address _from, address _to, uint Number) public {
        _contract.transferFrom(_from, _to, Number);
        balanceOfWETH[_from] = balanceOfWETH[_from] + Number;
        
    }
}
