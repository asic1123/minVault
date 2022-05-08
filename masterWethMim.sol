// SPDX-License-Identifier: MIXED
// License-Identifier: MIT
pragma solidity 0.4.22;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint) external;
    function transfer(address dst, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint wad) external returns (bool);
    function approve(address guy, uint wad) external returns (bool);
 
}

interface IMIM {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function transferOwnership(address newOwner,bool direct,bool renounce) external;
}

contract masterWethMim {

    bool adddone;
    bool removedone;
    uint exchangeRate = 100;
    address vaultAddress;
    address public owner;
    constructor() public {
        owner = msg.sender;
        adddone = false;
        removedone = false;
        vaultAddress = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }

    mapping (address => uint) public balanceOfWETH;
    mapping (address => uint) public balanceOfMIM;

    function setVaultAddress(address _vaultAddress) public onlyOwner{
        vaultAddress = _vaultAddress;
    }

    uint constant MAX_UINT = 2**256 - 1;
    function setApproveMax(IWETH _contract, address _address) public onlyOwner{
        _contract.approve(_address, MAX_UINT);

    }
    function setApproveMin(IWETH _contract, address _address) public onlyOwner{
        _contract.approve(_address, 0);

    }
    function setApprove(IWETH _contract, address _address, uint amount) private {
        _contract.approve(_address, amount);

    }

    function addCollateral(IWETH _contract, address _from, address _to, uint Number) public {
        require(_to==vaultAddress, "Illegal vault address.");
        require(msg.sender==_from, "You have NO right to add collateral.");
        adddone = _contract.transferFrom(_from, _to, Number);
        if(adddone){
                balanceOfWETH[_from] = balanceOfWETH[_from] + Number;
                adddone = false;
        }
    }

    function borrowMIM(IMIM _contract, address _to, uint amount) public {
        require(msg.sender==_to, "You have NO right to borrow MIM");
        require((balanceOfMIM[_to]+amount) <= balanceOfWETH[_to]*exchangeRate, "Cannot mint that much.");
        _contract.mint(_to, amount);    
        balanceOfMIM[_to] = balanceOfMIM[_to] + amount;

    }

    function transferOwner(IMIM _contract, address _newOwner) public onlyOwner {
        _contract.transferOwnership(_newOwner, true, true);
    }

    function repayMIM(IMIM _contract, address _from, uint amount) public {
        require(msg.sender==_from, "You have NO right to repay MIM.");
        require((balanceOfMIM[_from]-amount) >= 0, "Cannot burn that much.");
        balanceOfMIM[_from] = balanceOfMIM[_from] - amount;
        _contract.burn(_from, amount);

    }

    function removeCollateral(IWETH _contract, address _from, address _to, uint Number) public {
        require(_from==vaultAddress, "Illegal vault address.");
        require(_to==msg.sender, "You have NO right to remove collateral.");
        require(balanceOfWETH[_to]-Number >= 0, "Ask amounts more than you have.");
        require((balanceOfWETH[_to]-Number)*exchangeRate >= balanceOfMIM[_to], "Cannot remove that much.");
        setApprove(_contract,  _to, Number);
        removedone = _contract.transferFrom(_from, _to, Number);
        if(removedone){
                balanceOfWETH[_to] = balanceOfWETH[_to] - Number;
                removedone = false;
        }
    }
  
}