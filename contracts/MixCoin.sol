pragma solidity 0.5.17;

import "./MerkleTreeWithHistory.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./utils/SystemAccess.sol";

contract IVerifier {
    function verifyProof(bytes memory proof, uint256[6] memory input) public returns (bool);
}
//声明合约并继承
contract MixCoin is SystemAccess, MerkleTreeWithHistory {
    //合约面额
    uint256  _denomination;
    //存款笔数
    uint256 public _depositCount;
    //已使用Hash
    mapping(bytes32 => bool)  _nullifierHashes;
    //凭证库
    mapping(bytes32 => bool)  _commitments;
    //校验合约对象
    IVerifier  verifier;

    //构造方法
    constructor(
        IVerifier verifierAddress, //校验合约地址
        uint256 denomination, //合约面额
        uint32 merkleTreeHeight //树高度
    ) MerkleTreeWithHistory(merkleTreeHeight) public {
        require(denomination > 0, "denomination should be greater than 0");
        verifier = verifierAddress;
        _denomination = denomination;
        _operator = msg.sender;
    }

    //存款事件
    event Deposit(bytes32 indexed commitment, uint32 leafIndex, uint256 timestamp);

    //存款验证
    function deposit(bytes32 commitment, uint256 ethNum) external onlySys {
        //校验凭证是否存在
        require(!_commitments[commitment], "The commitment has been submitted");
        //校验金额与合约面额是否匹配
        require(ethNum == _denomination, "Please send `mixDenomination` ETH along with transaction");
        uint32 insertedIndex = _insert(commitment);
        _depositCount++;
        _commitments[commitment] = true;
        emit Deposit(commitment, insertedIndex, block.timestamp);
    }

    //取款事件
    event Withdrawal(address to, bytes32 nullifierHash, address relayer, uint256 fee);

    //取款验证
    function withdraw(bytes calldata proof, bytes32 root, bytes32 nullifierHash, address payable recipient, address payable relayer, uint256 fee, uint256 refund) external onlySys {
        require(fee <= _denomination, "Fee exceeds transfer value");
        require(!_nullifierHashes[nullifierHash], "The note has been already spent");
        require(isKnownRoot(root), "Cannot find your merkle root");
        require(verifier.verifyProof(proof, [uint256(root), uint256(nullifierHash), uint256(recipient), uint256(relayer), fee, refund]), "Invalid withdraw proof");
        _nullifierHashes[nullifierHash] = true;
        emit Withdrawal(recipient, nullifierHash, relayer, fee);
    }

    //是否已经取款
    function isSpent(bytes32 nullifierHash) public view returns (bool) {
        return _nullifierHashes[nullifierHash];
    }

    //是否已经取款
    function isSpentArray(bytes32[] calldata nullifierHashes) external view returns (bool[] memory spent) {
        spent = new bool[](nullifierHashes.length);
        for (uint i = 0; i < nullifierHashes.length; i++) {
            if (isSpent(nullifierHashes[i])) {
                spent[i] = true;
            }
        }
    }
}
