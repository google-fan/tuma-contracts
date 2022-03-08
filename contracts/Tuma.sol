// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

/**
 * ████████╗██╗   ██╗███╗   ███╗ █████╗     ███████╗ ██████╗ ██████╗      █████╗ ███████╗██████╗ ██╗ ██████╗ █████╗ 
 * ╚══██╔══╝██║   ██║████╗ ████║██╔══██╗    ██╔════╝██╔═══██╗██╔══██╗    ██╔══██╗██╔════╝██╔══██╗██║██╔════╝██╔══██╗
 *    ██║   ██║   ██║██╔████╔██║███████║    █████╗  ██║   ██║██████╔╝    ███████║█████╗  ██████╔╝██║██║     ███████║
 *    ██║   ██║   ██║██║╚██╔╝██║██╔══██║    ██╔══╝  ██║   ██║██╔══██╗    ██╔══██║██╔══╝  ██╔══██╗██║██║     ██╔══██║
 *    ██║   ╚██████╔╝██║ ╚═╝ ██║██║  ██║    ██║     ╚██████╔╝██║  ██║    ██║  ██║██║     ██║  ██║██║╚██████╗██║  ██║
 *    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝    ╚═╝      ╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TUMA is ERC20, Ownable {
  // Additional variables for use if transaction fees ever become necessary
    uint256 private _feeMaximum = 0;
    uint256 private _feePointRate = 0;
    uint8 private _feeDecimals = 4; // 0.01% when feePointRate is 1

    uint256 private constant tumaSupply = 700 * 10 ** 12 * 10 ** decimals();

    event FeeMaximumAmountUpdated(uint256 indexed feeMaximum_);
    event FeePointRateUpdated(uint256 indexed feePointRate_);

    constructor(string memory name_, string memory symbol_) ERC20 (name_, symbol_) {
        _mint(_msgSender(), tumaSupply);
    }

    function feePointRate () public view returns (uint256) {
        return _feePointRate;
    }

    function feeDecimals () public view returns (uint256) {
        return _feeDecimals;
    }

    function feeMaximum () public view returns (uint256) {
        return _feeMaximum;
    }

    function setFeeMaximum (uint256 feeMaximum_) public onlyOwner {
        _feeMaximum = feeMaximum_;

        emit FeeMaximumAmountUpdated(_feeMaximum);
    }

    function setFeePointRate (uint8 feePointRate_) public onlyOwner {
        _feePointRate = feePointRate_;

        emit FeePointRateUpdated(feePointRate_);
    }

    function transfer(address to_, uint256 amount_) public override returns (bool) {
        address sender = _msgSender();

        uint256 fee = amount_ * _feePointRate / (10 ** _feeDecimals);
        if (fee > _feeMaximum) {
            fee = _feeMaximum;
        }

        uint256 transferAmount = amount_ - fee;

        _transfer(sender, owner(), fee);
        _transfer(sender, to_, transferAmount);

        return true;
    }

    function transferFrom(address from_, address to_, uint256 amount_) public override returns (bool) {
        address spender = _msgSender();

        uint256 fee = amount_ * _feePointRate / (10 ** _feeDecimals);
        if (fee > _feeMaximum) {
            fee = _feeMaximum;
        }

        uint256 transferAmount = amount_ - fee;

        _spendAllowance(from_, spender, transferAmount);
        _transfer(from_, owner(), fee);
        _transfer(from_, to_, transferAmount);

        return true;
    }

    function reClaimCoin (address to_) public onlyOwner {
        require(to_ != address(0), "E-COIN: claim to the zero address");

        payable(to_).transfer(address(this).balance);
    }

    function reClaimToken (address token_, address to_) public onlyOwner {
        require(to_ != address(0), "E-COIN: claim to the zero address");
        require(token_ != address(0), "E-COIN: claim to the zero address");
        require(token_ != address(this), "E-COIN: self withdraw");

        uint256 tokenBalance = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transfer(to_, tokenBalance);
    }
}