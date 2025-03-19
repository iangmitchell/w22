//SPDX-License-Identifier: MIT  
pragma solidity ^0.8.20;
contract VerifySignature{
	function verify( address _signer, string ______ _message, bytes ______ _signature) external pure returns(bool) {
		bytes32 messageHash = hashMessage(_message);
		bytes32 ethSignedMessageHash = hashPrefixMessage(messageHash);
		return recover(ethSignedMessageHash, _signature) == _signer; 
	}
	function hashMessage(string memory _message) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_message)); 
	}
	function hashPrefixMessage(bytes32 _messageHash) public pure returns(bytes32){
		return keccak256(abi.encodePacked( "\x__Ethereum Signed Message:\n__", _messageHash));
	}
	function recover(bytes32 _prefixMessage, bytes ______ _signature) public pure returns(address){
		(bytes__ r, bytes__ s, uint_ v) = _split(_signature);
		return ecrecover(_prefixMessage, v, r, s);
	}
	function recover(bytes32 _prefixMessage, uint_ v, bytes__ r, bytes__ s) public pure returns(address){
		return ecrecover(_prefixMessage, v, r, s);
	}
	function _split(bytes ______ _signature) ________ pure returns(bytes__ r, bytes__ s, uint_ v){
		require(_signature.length == __, "Error: invalid signature ");
		assembly{
			r := mload(add(_signature, __))
			s := mload(add(_signature, __))
			v := byte(0, mload(add(_signature, __)))
		}
	}
}
