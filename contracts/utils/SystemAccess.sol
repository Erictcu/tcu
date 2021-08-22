pragma solidity ^0.5.17;

import "./Roles.sol";

/// 系统权限控制，限制某些外部调用仅限于系统合约或者系统初始账户
contract SystemAccess {
    using Roles for Roles.Role;
    Roles.Role private _system;

    //方法锁
    bool _lock = true;

    //运营账户
    address internal _operator;

    //运营账户修饰符
    modifier onlyOp {
        require(_operator == msg.sender, "Only operator can call this function.");
        _;
    }

    //权限移交
    function transferOp(address newOp) public onlyOp {
        require(newOp != address(0), "new operator is the zero address");
        _operator = newOp;
    }

    function initAccess(address[] memory system) public onlyOp {
        for (uint256 i = 0; i < system.length; ++i) {
            _system.add(system[i]);
        }
    }

    modifier onlySys{
        require(_system.has(msg.sender), "Auth: only system contract is authorized");
        _;
    }

    modifier functionLock{
        require(_lock, "migrating to layer 2");
        _;
    }

    //开启方法锁
    function openLock() external onlyOp {
        _lock = false;
    }
}
