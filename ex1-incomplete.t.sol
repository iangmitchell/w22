//SPDX-License-Identifier:MIT
pragma solidity ^0.8.2;
import {Test, console} from "forge-std/Test.sol";
import {VerifySignature} from "../src/verSig.sol";
contract verSigTest is Test{
  VerifySignature public vs;
  string constant pt = 'hello';
  function setUp() public{
    vs = new VerifySignature();
  }
  function test_hash() public view{
    bytes32 hm1 =vs.hashMessage(pt);
    bytes32 hm2 =_________(___.____________(pt));
    assertEq(hm1, hm2);
  }
  function test_hashPrefix() public view{
    bytes32 hm1 =vs.hashMessage(pt);
    bytes32 hm2 =_________(___.____________(pt));
    bytes32 phm1 = vs.hashPrefixMessage(hm1);
    bytes32 phm2 = _________(________________(__________________________________, hm2));
    assertEq(phm1, phm2);
  }
  function test_sign() public view {
    uint256 privateKey = 4125;
    address pubKey = vm.addr(privateKey);
    bytes32 hm1 =vs.hashMessage(pt);
    bytes32 hm2 =_________(___.____________(pt));
    bytes32 phm1 = vs.hashPrefixMessage(hm1);
    bytes32 phm2 = _________(________________(__________________________________, hm2));
    (uint8 _, bytes32 _, bytes32 _) = vm.sign(privateKey, phm1);
    address signer2 = _________(phm2, _, _, _);
    address signer1 = vs.recover(phm1, _, _, _);
    assertEq(signer2, ______);
    assertEq(signer2, _______);
  }
  function test_verify() public view {
    uint256 privateKey = 4125;
    address pubKey = vm.addr(privateKey);
    bytes32 hm2 =	_________(________________(pt));
    bytes32 phm2 = _________(________________(__________________________________, hm2));
    (uint8 _, bytes32 _, bytes32 _) = vm.sign(privateKey, phm2);
    assertTrue( vs.verify(______, pt, _, _, _ ));
  }
}
