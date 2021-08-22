pragma solidity ^0.5.17;

library RandomUtil {
    //生成随机数
    function rand(uint256 _length) internal view returns (uint256) {
        uint256 random =
            uint256(keccak256(abi.encodePacked(block.difficulty, now)));
        return random % _length;
    }
}
