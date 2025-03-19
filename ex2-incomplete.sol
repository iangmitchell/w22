//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MultiSignatureWallet{
	event Deposit(address indexed sender, uint amount);
	event Submit(uint indexed txId);
	event Approve(address indexed owner, uint indexed txId);
	event Revoke(address indexed owner, uint indexed txId);
	event Execute(uint indexed txId);
	struct Transaction{
		address to;
		uint value;
		bytes data;
		bool executed;
		}
	address[] public owners;
	mapping(address => bool) public isOwner;
	uint public required;
	Transaction[] public transactions;
	mapping(uint => mapping(address => bool)) public approved;
	modifier onlyOwner(){
		...
		_;
		}
	modifier txExists(uint _txId){
		...
		_;
		}
	modifier notApproved(uint _txId){
		...
		_;
		}
	modifier notExecuted(uint _txId){
		_;
		}
	constructor(address[] ______ _owners, uint _required){...}
	receive() external _______{
		emit Deposit(msg.sender, msg.value);
		}
	function submit( address _to, uint _value, bytes calldata _data) external onlyOwner{
		transactions.____(Transaction({
			to: _to,
			value: _value,
			data: _data,
			executed: false
			}));
		emit Submit(transactions.length - 1);
	}
	function approve(uint _txId)
		external
		onlyOwner
		txExists(_txId)
		notApproved(_txId)
		notExecuted(_txId)
	{...}
	function _getApprovalCount( uint _txId) private view returns (uint count){...}
	function execute(uint _txId) external txExists(_txId) ___________(_txId) {...}
	function revoke(uint _txId)
		external
		onlyOwner
		txExists(_txId)
		notExecuted(_txId)
		{...}
}
