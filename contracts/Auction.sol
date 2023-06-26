// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Auction is IERC721Receiver {
    IERC721 private nft;
    struct InfoAuction {
        uint id;
        // owner and info nft
        address seller;
        uint tokenIdNft;
        // bid auction
        uint256 initprice;
        uint256 highestBid;
        address highestBidder;
        // time
        uint256 timeStart;
        uint256 timeEnd;
        //
        bool isSale;
    }

    mapping(uint256 => InfoAuction) public info;
    mapping(address => uint) public bids;
    mapping(address => uint256[]) public userAuctions;
    // using Counters for Counters.Counter;
    // Counters.Counter public  _idAuction;

    using Counters for Counters.Counter;
    Counters.Counter public _auctionIds;

    bool public hasStarted;
    bool public hasEnded;

    constructor(IERC721 _nft) {
        nft = _nft;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function createAution(uint256 _nftTokenId, uint256 _startingPrice) public {
        _auctionIds.increment();
        uint256 idAuction = _auctionIds.current();
        InfoAuction storage stk = info[idAuction];
        info[idAuction] = InfoAuction(
            stk.id = idAuction,
            stk.seller = msg.sender,
            stk.tokenIdNft = _nftTokenId,
            stk.initprice = _startingPrice,
            stk.highestBid = 0,
            stk.highestBidder = address(0),
            stk.timeStart = block.timestamp,
            stk.timeEnd = block.timestamp + 45 minutes,
            stk.isSale = false
        );
        userAuctions[msg.sender].push(idAuction);
        nft.safeTransferFrom(msg.sender, address(this), _nftTokenId);
    }

    function participateAution(uint256 _idAuction) external payable {
        InfoAuction storage stk = info[_idAuction];
        require(msg.value > stk.highestBid, "value < highest bid");
        require(msg.value > stk.initprice, "value < highest initprice");
        require(block.timestamp >= stk.timeStart, "Auction has not started");
        require(stk.isSale == false, "Auction is already completed");

        if (stk.highestBidder != address(0)) {
            bids[stk.highestBidder] += stk.highestBid;
            payable(stk.highestBidder).transfer(stk.highestBid);
            bids[stk.highestBidder] = 0;
        }
        stk.highestBidder = msg.sender;
        stk.highestBid = msg.value;
    }

    function claimNftEndTime(uint256 _idAuction) public {
        InfoAuction storage stk = info[_idAuction];
        require(stk.isSale == false, "not started");
        require(block.timestamp >= stk.timeEnd, "Alredy timeEnd");
        nft.safeTransferFrom(address(this), stk.highestBidder, stk.tokenIdNft);
        stk.isSale = true;
    }

    function cancelAution(uint256 _idAuction) public {
        InfoAuction storage stk = info[_idAuction];
        require(stk.isSale == false, "not started");
        require(msg.sender == stk.seller, "You are not owner NFT");
        nft.safeTransferFrom(address(this), stk.seller, stk.tokenIdNft);
    }

    function getAuction(
        uint256 _auctionId
    ) public view returns (InfoAuction memory) {
        return info[_auctionId];
    }

    function getUserAuctions(
        address user
    ) public view returns (uint256[] memory) {
        return userAuctions[user];
    }
}
