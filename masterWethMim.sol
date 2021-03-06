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
    uint public price;
    address vaultAddress;
    address wethAddress;
    address mimAddress;
    address public owner;
    constructor() public {
        adddone = false;
        removedone = false;
        price = 100;
        vaultAddress = msg.sender;
        owner = msg.sender;
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

    function setWethAddress(address _wethAddress) public onlyOwner{
        wethAddress = _wethAddress;
    }
    
    function setMimAddress(address _mimAddress) public onlyOwner{
        mimAddress = _mimAddress;
    }

    function setPrice(uint _price) public onlyOwner{
        price = _price;
    }

    function setApprove(IWETH _contract, address _address, uint amount) private {
        _contract.approve(_address, amount);
    }

 //   function addCollateral(IWETH _contract, address _from, address _to, uint Number) public {
     function addCollateral(uint Number) public {
        IWETH _contract;
        _contract =  IWETH(wethAddress);
        address _to = vaultAddress;
        address _from = msg.sender;
        require(Number > 0, "Wrong input number.");
        require(Number < 100000000000000000000000000, "Less than 100 millions processing at one time.");
 //       require(_to==vaultAddress, "Illegal vault address.");
 //       require(msg.sender==_from, "You have NO right to add collateral.");
 //       _contract.approve(vaultAddress, Number);
 //       setApprove(_contract, vaultAddress, Number);
 //     Approve function must be executed in frontend app. here msg.sender is vaultAddress, guy is vaultAddress. it means vaultAddress approve vaultAddress using Number tokens.
        adddone = _contract.transferFrom(_from, _to, Number);
        if(adddone){
                balanceOfWETH[_from] = balanceOfWETH[_from] + Number;
                adddone = false;
        }
    }

    function readCollateral() external view returns(uint) {
        return balanceOfWETH[msg.sender];
    }

    function readMim() external view returns(uint) {
        return balanceOfMIM[msg.sender];
    }

//    function borrowMIM(IMIM _contract, address _to, uint amount) public {
    function borrowMIM(uint amount) public {
//        require(msg.sender==_to, "You have NO right to borrow MIM");
        IMIM _contract;
        _contract =  IMIM(mimAddress);
        address _to = msg.sender;
        require((balanceOfMIM[_to]+amount) <= balanceOfWETH[_to]*price, "Cannot mint that much.");
        _contract.mint(_to, amount);    
        balanceOfMIM[_to] = balanceOfMIM[_to] + amount;
    }

    function transferOwner(IMIM _contract, address _newOwner) public onlyOwner {
        _contract.transferOwnership(_newOwner, true, true);
    }

 //   function repayMIM(IMIM _contract, address _from, uint amount) public {
    function repayMIM(uint amount) public {
 //       require(msg.sender==_from, "You have NO right to repay MIM.");
        IMIM _contract;
        _contract =  IMIM(mimAddress);
        address _from = msg.sender;
        require((balanceOfMIM[_from]-amount) >= 0, "Cannot burn that much.");
        _contract.burn(_from, amount);
        balanceOfMIM[_from] = balanceOfMIM[_from] - amount;
    }

 //   function removeCollateral(IWETH _contract, address _from, address _to, uint Number) public {
    function removeCollateral(uint Number) public {
//        require(_from==vaultAddress, "Illegal vault address.");
//        require(_to==msg.sender, "You have NO right to remove collateral.");
        address _to = msg.sender;
        address _from = vaultAddress;
        require(Number > 0, "Wrong input number.");
        require(Number < 100000000000000000000000000, "Less than 100 millions processing at one time.");
        require(balanceOfWETH[_to] >= Number, "Ask amounts more than you have.");
        require((balanceOfWETH[_to]-Number)*price >= balanceOfMIM[_to], "Cannot remove that much.");
        IWETH _contract;
        _contract =  IWETH(wethAddress);
        setApprove(_contract, _to, Number);
        removedone = _contract.transferFrom(_from, _to, Number);
        if(removedone){
                balanceOfWETH[_to] = balanceOfWETH[_to] - Number;
                removedone = false;
        }
    }
}