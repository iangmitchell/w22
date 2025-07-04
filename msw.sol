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
	// txId mapped to address
	// keeps track of which tx has been approved 
	// once required is reached
	mapping(uint => mapping(address => bool)) public approved;
	// cannot use OZ's onlyOwner, this is different
	modifier onlyOwner(){
		require(isOwner[msg.sender], "Error: Address is not an owner of the Wallet");
		_;
		}
	modifier txExists(uint _txId){
		require(_txId < transactions.length, "Error: transaction does not exist");
		_;
		}
	modifier notApproved(uint _txId){
		require(!approved[_txId][msg.sender], "Error: transaction is already approved");
		_;
		}
	modifier notExecuted(uint _txId){
		require(!transactions[_txId].executed, "Error: already executed");
		_;
		}

	constructor(address[] memory _owners, uint _required){
		require(_owners.length > 0, "Error: owners are required");
		require(_required>0 && required <=_owners.length, "Error: invalid number of required owners");
		for(uint i; i<_owners.length; ){
			address owner = _owners[i];
			require(owner!=address(0), "Error: invalid address");
			require(!isOwner[owner], "Owner is not unique");
			isOwner[owner]=true;
			owners.push(owner);
			unchecked{
				i++;
			}
		}
		required=_required;
	}

	
	receive() external payable{
		emit Deposit(msg.sender, msg.value);
		}

	function getOwner(uint idx) public view returns(address){
		return(owners[idx]);
	}

	function contribute() public payable onlyOwner{
		address _owner = msg.sender;
		require(_owner.balance >= msg.value, "insufficient funds");
		address _escrow = payable(address(this));
		(bool sent, ) = _escrow.call{value:msg.value}("");
		require(sent, "tx failed");
	}	

	function submit( address _to, uint _value, bytes calldata _data) external onlyOwner{
		transactions.push(Transaction({
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
	{
		approved[_txId][msg.sender] = true;
		emit Approve(msg.sender, _txId);
	}

	function _getApprovalCount( uint _txId) private view returns (uint count){
		for(uint i; i< owners.length; i++){
			if(approved[_txId][owners[i]]){
				count +=1;
				}
			}
	}

	function execute(uint _txId) external payable txExists(_txId) notExecuted(_txId) {
		require(_getApprovalCount(_txId) >= required, "Error: approvals < required ");
		Transaction storage tx = transactions[_txId];
		tx.executed = true;
		address to = payable(tx.to);
		(bool success, ) = to.call{value:tx.value}(tx.data);
		require(success, "Error: transaction failed");
		emit Execute(_txId);
	}

	function revoke(uint _txId)
		external
		onlyOwner
		txExists(_txId)
		notExecuted(_txId)
		{
		require(approved[_txId][msg.sender], "Error: transaction is not approved");
		approved[_txId][msg.sender] = false;
		emit Revoke(msg.sender, _txId);
		}

}
