// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { MerkleProof } from "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import { ReentrancyGuard } from "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

interface INFTAuction {
    // Event declarations
    event UpdateNewRound(uint256 indexed round);
    event StartAuction(int256 indexed x, int256 indexed y, uint256 indexed round, address firstOwner, uint256 amount, uint256 ends);
    event NewBid(int256 indexed x, int256 indexed y, address owner, uint256 amount, uint256 ends);

    // Token management functions
    function burnTokens(uint256 amount) external;
    function sendTokens(uint256 amount) external;

    // Auction management functions
    function startAuction(int256 x, int256 y, bytes32[] calldata proof) external;
    function bidPlot(int256 x, int256 y, uint256 amount) external;
    function tradeStatus(int256 x, int256 y) external view returns(bool started, bool finished);

    // Plot management functions
    function getPlotRound(int256 x, int256 y) external view returns (uint256);
    function getPlotPrice(int256 x, int256 y) external view returns(uint256);
    function getPlotOwner(int256 x, int256 y) external view returns(address);
    function getPlotDetails(int256 x, int256 y) external view returns(uint256 price, address owner, bool isFinal);
    
    // Additional utility functions
    function expectedRound() external view returns (uint256);
    function setNextPrice(uint256 _nextPrice) external;
    function getHash(int256 x, int256 y, uint256 round) external pure returns(bytes32);
    function timeLeft(int256 x, int256 y) external view returns(int256);
}

error NotStartAuction(uint256 startDate, uint256 blockTimestamp);
error InvalidProof(int256 x, int256 y, uint256 round);
error PlotAlreadyOwned(int256 x, int256 y, uint256 round);
error AlreadySold();
error AuctionNotStarted(uint256 startDate, uint256 blockTimestamp);
error AuctionFinished();
error InvalidBid(uint256 minimumBid);
error BidTooLow(uint256 minimumBid);
error BidTooLate();

/// @title NFT Auction Contract
/// @notice This contract manages the auction of NFT plots
contract NFTAuction is INFTAuction, Ownable, ReentrancyGuard {
    using MerkleProof for bytes32[];

    uint256 public constant PERIOD_LENGTH = 7 days;
    uint256 public constant INITIAL_PERIOD = 2 days;
    uint256 public constant BID_TIMEOUT = 2 hours;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    IERC20 public paymentToken;

    bytes32 public merkleRoot;

    uint256 public startDate;

    uint256 public currentRound;
    uint256 public startPrice;
    uint256 public nextStartPrice;

    struct PlotDetails {
        uint256 round;
        uint256 price;
        address owner;
        uint256 endTime;
    }

    mapping(bytes32 => PlotDetails) public plots;

    mapping(bytes32=>address) public tokenOwner;
    mapping(bytes32=>uint256) public highestPrice;
    mapping(bytes32=>uint256) public auctionEndTime;

    constructor(bytes32 _merkleRoot, address _paymentTokenAddress, uint256 _startDate) {
        paymentToken = IERC20(_paymentTokenAddress);

        merkleRoot = _merkleRoot;

        currentRound = 1;
        startPrice = 20000 * 10**18;
        nextStartPrice = startPrice;
        startDate = _startDate;

        emit UpdateNewRound(currentRound);
    }

    /// @dev Burns a specific amount of tokens by transferring them to the dead address.
    ///      This function can only be called by the contract owner.
    /// @param amount The amount of tokens to burn.
    function burnTokens(uint256 amount) external onlyOwner {
        paymentToken.transfer(deadAddress, amount);
    }

    /// @dev Transfers a specified amount of tokens to the owner of the contract.
    ///      This function can only be called by the contract owner.
    /// @param amount The amount of tokens to be transferred.
    function sendTokens(uint256 amount) external onlyOwner {
        paymentToken.transfer(owner(), amount);
    }

    /// @dev Advances the current round by one and updates the start price. 
    ///      This function also emits an event indicating the start of a new round.
    function changeRound() internal {
        currentRound += 1;
        startPrice = nextStartPrice;
        emit UpdateNewRound(currentRound);
    }

    /// @dev Calculates and returns the expected round based on the current block timestamp and the start date of the contract.
    ///      The calculation is performed as follows: 1 + (current block timestamp - contract start date) / period length.
    ///      This function is marked as 'view' because it does not modify the state.
    /// @return The expected round number calculated based on the current block timestamp and the contract start date.
    function expectedRound() public view returns(uint256) {
        return 1 + ((block.timestamp - startDate) / PERIOD_LENGTH);
    }

    /// @dev Sets the next start price for the auction.
    ///      This function can only be called by the owner of the contract.
    /// @param _nextPrice The value to be set as the next start price.
    function setNextPrice(uint256 _nextPrice) external onlyOwner {
        nextStartPrice = _nextPrice;
    }

    /// @dev Generates and returns a unique hash for a given x, y coordinate pair and a round number using the keccak256 hash function.
    /// @param x The x coordinate for which the hash is to be generated.
    /// @param y The y coordinate for which the hash is to be generated.
    /// @param round The round number for which the hash is to be generated.
    /// @return A unique hash for the provided x, y coordinate pair and round number.
    function getHash(int256 x, int256 y, uint256 round) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(x, y, round));
    }

    /// @dev Gets the highest price for a plot located at given x, y coordinates by generating a hash with round number 0. 
    ///      It then uses this hash to lookup the highest price from the 'highestPrice' mapping.
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return The highest price for the plot located at the given x, y coordinates.
    function getPlotRound(int256 x, int256 y) public view returns(uint256) {
        return highestPrice[getHash(x, y, 0)];
    }

    /// @dev Starts the auction for the plot at the given x, y coordinates after verifying the provided proof.
    ///      The sender of the transaction must send the start price as payment.
    ///      This function can only be called after the start date of the auction has passed and if the plot is not already owned.
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @param proof The proof to be verified in order to start the auction.
    function startAuction(int256 x, int256 y, bytes32[] calldata proof) external nonReentrant() {
        if (block.timestamp < startDate)
            revert AuctionNotStarted({
                startDate: startDate,
                blockTimestamp: block.timestamp
            });

        while(expectedRound() > currentRound){
            changeRound();
        }

        bytes32 currentPlotHash = getHash(x, y, currentRound);
        bytes32 zeroRoundPlotHash = getHash(x, y, 0);

        // invalid-proof
        if (!MerkleProof.verify(proof, merkleRoot, currentPlotHash))
            revert InvalidProof({
                x: x,
                y: y,
                round: currentRound
            });

        uint256 plotRound = getPlotRound(x, y);

        // already-sold
        if (plotRound != 0)
            revert PlotAlreadyOwned({
                x: x,
                y: y,
                round: plotRound
            });

        paymentToken.transferFrom(msg.sender, address(this), startPrice);
        highestPrice[zeroRoundPlotHash] = currentRound;
        tokenOwner[currentPlotHash] = msg.sender;
        auctionEndTime[currentPlotHash] = block.timestamp + INITIAL_PERIOD;
        highestPrice[currentPlotHash] = startPrice;

        emit NewBid(x, y, msg.sender, startPrice, auctionEndTime[currentPlotHash]);
        emit StartAuction(x, y, currentRound, msg.sender, startPrice, auctionEndTime[currentPlotHash]);
    }

    function sendTokens(address to, uint256 amount) internal {
        paymentToken.transfer(to, amount);
    }

    /// @dev Bids on a plot at the given x, y coordinates with the specified amount. 
    ///      The sender of the transaction must send the bid amount as payment.
    ///      The bid must be at least 10 percent higher than the current highest price and 
    ///      the auction for the plot must still be ongoing.
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @param amount The amount of the bid.
    function bidPlot(int256 x, int256 y, uint256 amount) external nonReentrant {
        bytes32 plotHash = keccak256(abi.encodePacked(x, y, currentRound));

        PlotDetails storage plot = plots[plotHash];

        require(amount > plot.price, "Bid not high enough");
        require(plot.endTime == 0 || plot.endTime > block.timestamp, "Plot not for sale");
        
        if (plot.endTime == 0) {
            plot.endTime = block.timestamp + BID_TIMEOUT;
        }

        sendTokens(plot.owner, plot.price);

        plot.price = amount;
        plot.owner = msg.sender;
    }

    /// @dev Provides trading status for a plot at the given x, y coordinates. 
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return started A boolean indicating whether the auction has started.
    /// @return finished A boolean indicating whether the auction has finished.
    function tradeStatus(int256 x, int256 y) external view returns(bool started, bool finished){
        uint256 round = getPlotRound(x, y);
        started = (round != 0);
        finished = (round != currentRound);
        return (started, finished);
    }

    /// @dev Returns the current highest price for a plot at the given x, y coordinates. 
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return The current highest price of the plot. Returns 0 if auction for the plot has not started.
    function getPlotPrice(int256 x, int256 y) external view returns(uint256){
        uint256 round = getPlotRound(x, y);
        if(round == 0){
            return 0;
        }
        return highestPrice[getHash(x, y, round)];
    }

    /// @dev Returns the current owner of a plot at the given x, y coordinates. 
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return The current owner of the plot. Returns the zero address if the plot has no owner.
    function getPlotOwner(int256 x, int256 y) external view returns(address){
        uint256 round = getPlotRound(x, y);
        if(round == 0){
            return address(0);
        }
        return tokenOwner[getHash(x, y, round)];
    }

    /// @dev Returns the time left in seconds until the auction for the plot ends. 
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return The time left in seconds until the auction for the plot ends. If the round isn't current or hasn't started yet, returns 0.
    function timeLeft(int256 x, int256 y) public view returns(int256){
        uint256 round = getPlotRound(x, y);
        if(round != currentRound){
            return 0;
        }
        return int256(auctionEndTime[getHash(x, y, round)]) - int256(block.timestamp);
    }

    /// @dev Returns the details of a specific plot.
    /// @param x The x coordinate of the plot.
    /// @param y The y coordinate of the plot.
    /// @return price The highest bid price for the plot.
    /// @return owner The current owner of the plot.
    /// @return isFinal Whether the auction for the plot has ended.
    function getPlotDetails(int256 x, int256 y) public view  returns(uint256 price, address owner, bool isFinal){
        uint256 round = highestPrice[getHash(x, y, 0)];
        bytes32 plotHash = getHash(x, y, round);
        return (highestPrice[plotHash], tokenOwner[plotHash], timeLeft(x, y) <= 0);
    }
}
