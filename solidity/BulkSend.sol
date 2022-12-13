// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract BulkSend is Ownable {
    using SafeERC20 for IERC20;

    struct ERC20TransferTask {
        address to;
        uint256 amount;
    }

    struct ERC721TransferTask {
        address to;
        uint256 id;
    }

    struct ERC1155TransferTask {
        address to;
        uint256 id;
        uint256 amount;
    }

    uint256 public fee;

    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }

    function erc20send(IERC20 token, ERC20TransferTask[] calldata tasks) external payable {
        redirectFee();
        for(uint256 i=0; i<tasks.length; i++) {
            ERC20TransferTask memory task = tasks[i];
            token.safeTransferFrom(msg.sender, task.to, task.amount);
        }
    }

    function erc721send(IERC721 token, ERC721TransferTask[] calldata tasks) external payable {
        redirectFee();
        for(uint256 i=0; i<tasks.length; i++) {
            ERC721TransferTask memory task = tasks[i];
            token.safeTransferFrom(msg.sender, task.to, task.id);
        }
    }

    function erc1155send(IERC1155 token, ERC1155TransferTask[] calldata tasks) external payable {
        redirectFee();
        for(uint256 i=0; i<tasks.length; i++) {
            ERC1155TransferTask memory task = tasks[i];
            token.safeTransferFrom(msg.sender, task.to, task.id, task.amount, bytes(""));
        }
    }

    function redirectFee() internal {
        if(fee > 0) {
            require(msg.value == fee, "Wrong fee");
            payable(owner()).transfer(fee);
        }
        
    }
}