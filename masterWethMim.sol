// SPDX-License-Identifier: MIXED
// License-Identifier: MIT
pragma solidity 0.4.22;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
 
}

interface IMIM {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function transferOwnership(address newOwner,bool direct,bool renounce) external;
}

contract masterWethMim {

    bool adddone;
    uint exchangeRate = 100;
    address legalAddress;
    address public owner;
    constructor() public {
        owner = msg.sender;
        adddone = false;
        legalAddress = 0x7b4D5058463cd4D15368756f5e13a34e70524D88;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    mapping (address => uint) public balanceOfWETH;
    mapping (address => uint) public balanceOfMIM;

    function addCollateral(IWETH _contract, address _from, address _to, uint Number) public {
        require(_to==legalAddress, "illegal vault address.");
        adddone = _contract.transferFrom(_from, _to, Number);
        if(adddone){
                balanceOfWETH[_from] = balanceOfWETH[_from] + Number;
                adddone = false;
        }
    }

    function borrowMIM(IMIM _contract, address _to, uint amount) public {
        require((balanceOfMIM[_to]+amount) <= balanceOfWETH[_to]*exchangeRate, "cannot mint that much.");
        require(msg.sender==_to, "You have NO right to borrow MIM");
        _contract.mint(_to, amount);    
        balanceOfMIM[_to] = balanceOfMIM[_to] + amount;

    }

    function transferOwner(IMIM _contract, address _newOwner) public onlyOwner {
        _contract.transferOwnership(_newOwner, true, true);
    }
  
}
