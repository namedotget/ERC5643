// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC5643.sol";
import {MoonDaoEntityTableland} from "../src/tables/MoonDaoEntityTableland.sol";
import {EntityRowController} from "../src/tables/EntityRowController.sol";
import {MoonDAOEntityCreator} from "../src/MoonDAOEntityCreator.sol";
import {IHats} from "@hats/Interfaces/IHats.sol";
import {Whitelist} from "../src/Whitelist.sol";

contract ERC5643Test is Test {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);

    address user1 = address(0x43b8880beE7fAb93F522AC8e121FF13fB77AF711);
    address user2 = address(0x2);
    address user3 = address(0x3);
    address user4 = address(0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7);
    uint256 tokenId = 0;
    uint256 tokenId2 = 1;
    uint256 tokenId3= 2;
    string uri = "https://test.com";
    MoonDAOEntity erc5643;
    MoonDAOEntityCreator creator;
    MoonDaoEntityTableland table;

    function setUp() public {
      vm.deal(user1, 10 ether);
      vm.deal(user2, 10 ether);

      vm.startPrank(user4);

      IHats hats = IHats(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);

      Whitelist whitelist = new Whitelist();

      table = new MoonDaoEntityTableland("MoonDaoEntityTable");

      uint256 moonDaoEntityEdminHatId = hats.createHat(8303663573482397056757440646802046247480240482142496324179911956758528, "", 1, user4, 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, true, "");
      // controller = new EntityRowController(address(table));

      erc5643 = new MoonDAOEntity("erc5369", "ERC5643", 0x09224bC4a1Ea9ce55E953bFab083A055eC4d19B7, 0x3bc1A0Ad72417f2d411118085256fC53CBdDd137);
      creator = new MoonDAOEntityCreator(0x3bc1A0Ad72417f2d411118085256fC53CBdDd137, address(erc5643), 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA, 0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC, address(table), address(whitelist));

      creator.setOpenAccess(true);

      table.setMoonDaoEntity(address(erc5643));

      creator.setMoonDaoEntityEdminHatId(moonDaoEntityEdminHatId);

      hats.mintHat(moonDaoEntityEdminHatId, address(creator));
      hats.changeHatEligibility(moonDaoEntityEdminHatId, address(creator));

      vm.stopPrank();
    }

    function testMint() public {
      vm.prank(user1);
      creator.createMoonDAOEntity{value: 0.1 ether}("", "","name", "bio", "image", "twitter", "communications", "website", "view", "formId");
    }

    function testUpdateTable() public {
      vm.prank(user1);
      (uint256 topHatId, uint256 hatId) = creator.createMoonDAOEntity{value: 0.1 ether}("", "", "name", "bio", "image", "twitter", "communications", "website", "view", "formId");

      // vm.prank(user4);
      // table.updateTable(0, hatId, "name", "bio", "image", "twitter", "communications", "website", "view", "formId");
      bool isAdmin = erc5643.isManager(0, user1);
      assertTrue(isAdmin);

      bool isAdmin2 = erc5643.isManager(0, user4);
      assertFalse(isAdmin2);
    }
}