pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./TaraAuction.sol";

contract TaraMarket is ERC721Full, Ownable {

    constructor() ERC721Full("TaraMarket", "TARA") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => TaraAuction) public auctions;

    modifier landRegistered(uint token_id) {
        require(_exists(token_id), "NFT not registered!");
        _;
    }

    function registerLand(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(foundation_address, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new TaraAuction(foundation_address);
    }

    function endAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        TaraAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        TaraAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
        TaraAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view landRegistered(token_id) returns(uint) {
        TaraAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable landRegistered(token_id) {
        TaraAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}
