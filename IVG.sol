// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract invisiblegoblin is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    
    Counters.Counter private _tokenIdCounter;
    
    string public baseURI; 
    bool public paused = false; 
    uint256 public cost = 0  ether; 
    uint256 public maxSupply = 1000; 
    uint256 public maxMintAmount = 10; 
    uint256 public currentIndex = 0;

    constructor() ERC721("Invisible Goblin v6", "IVG") payable {
        safeMint(msg.sender, 0);
    }


    function safeMint(address to, uint256 tokenId) private onlyOwner {
        _safeMint(to, tokenId);
        currentIndex += 1;

    }
    function mint(uint256 _mintAmount) public payable {
        require(paused != true, "Sale must be active");
        require(_mintAmount > 0); 
        require(_mintAmount +balanceOf(msg.sender) <= maxMintAmount, "You can only adopt 10 Invisible Goblin");
        require(cost * _mintAmount <= msg.value, "Ether value sent is not correct"); 
        require(currentIndex + _mintAmount < maxSupply-1, "Out of Supply Token");

        for(uint256 i = 0; i < _mintAmount; i++) {
            uint256 mintIndex = _tokenIdCounter.current() + 1;

            if (mintIndex <= maxSupply) {
                _safeMint(msg.sender, mintIndex);
                _tokenIdCounter.increment();
                
            }
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = baseURI;
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, "/", Strings.toString(tokenId), ".json")) : "";
    }

    function totalSupply() public view override returns (uint256) {
        return currentIndex;
    }

    function setCost(uint256 _newCost) public onlyOwner() {
        cost = _newCost;
    }
    

    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner() {
        maxSupply = _newMaxSupply;
    }
    
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
    }
    
    function pause() public onlyOwner {
        paused = !paused;
    }

}
