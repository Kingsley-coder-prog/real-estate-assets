// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract RealEstateAssets {

    uint public assetPrice;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Released, Inactive }
    State public state;
    

    constructor() payable {
        seller = payable(msg.sender);
        assetPrice = 2 ether;
    }

    /// The function cannot be invoked at the current state
    error invalidState();
    /// Only Buyer can invoke this function
    error onlyBuyer();
    /// Only Seller can invoke this function
    error onlySeller();

    modifier inState(State _state) {
        if(state != _state) {
            revert invalidState();
        }
        _;
    }

    modifier OnlyBuyer() {
        if(msg.sender != buyer) {
            revert onlyBuyer();
        }
        _;
    }

    modifier OnlySeller() {
        if(msg.sender != seller) {
            revert onlySeller();
        }
        _;
    }

    function confirmPurchase() external inState(State.Created) payable {
        require(msg.value == (2 * assetPrice), "You have to pay 2x the purchasing value.");
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    function confirmProperty() external OnlyBuyer inState(State.Locked) {
        state = State.Released;
        buyer.transfer(assetPrice);
    }

    function paySeller() external OnlySeller inState(State.Released) {
        state = State.Inactive;
        seller.transfer(3 * assetPrice);
    }

    function abortDeal() external OnlySeller inState(State.Created) {
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }
}
