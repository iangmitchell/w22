const{ethers} = require("hardhat")
const{expect} = require("chai");


describe("MSW", ()=>{
	let owner1, owner2, owner3, addr1, addr2
	let contract
	let oneEth = ethers.parseEther("1")
	let required=2;
	let maxOwners=3;
	let owners = new Array()
	let contractAddress
	before("Get accounts", async()=>{
		[owner1, owner2, owner3, addr1, addr2] = await ethers.getSigners()
		owners.push(owner1.address)
		owners.push(owner2.address)
		owners.push(owner3.address)
	})
	beforeEach("Deploy", async()=>{
		let Contract = await ethers.getContractFactory("MultiSignatureWallet")
		contract = await Contract.deploy(owners, required)
		await contract.waitForDeployment()
		contractAddress = await contract.address;
	})
	it("isOwner", async()=>{
		let testOwner = await contract.getOwner(0);
		console.log("Test owner:", testOwner)
		owners.forEach(x=>console.log(x))
		expect( testOwner).to.equal(owner1.address)
		owners.forEach( async(x,i)=>{
			expect( await contract.getOwner(i)).to.equal(x)
		})
	})
	it("contribute", async()=>{
		expect( await contract.contribute({value:oneEth})).to.changeEtherBalances([owner1, contractAddress], [-oneEth, oneEth]);
	})
	it("contribute revert", async()=>{
		await expect( contract.connect(addr1).contribute({value:oneEth})).to.be.reverted
	})
	describe("submit", ()=>{
		it("emit", async()=>{
			expect( await contract.submit(addr1.address, oneEth, "0x")).to.emit(
				contract,
				"Submit")
		})
		it("onlyOwner", async()=>{
			await expect( contract.connect(addr1).submit(addr1.address, oneEth, "0x")).to.be.reverted;
		})
	})
	describe("Approve", ()=>{
		let tId = 0;
		beforeEach("submit before approve", async()=>{
			await contract.submit(addr1.address, oneEth, "0x")				
		})
		it("Approve non owner revert", async()=>{
			await expect( contract.connect(addr2).approve(tId)).to.be.reverted
		})
		it("Approve tx does not exist", async()=>{
			await expect( contract.approve(tId+1)).to.be.reverted
		})
		it("Approved", async()=>{
			expect( await contract.approve(tId)).to.emit(
				contract, 
				"Approve")
		})
	})
	describe("execute", ()=>{
		let tId=0;
		beforeEach("submit and approve", async()=>{
			await contract.submit(addr1.address, oneEth, "0x")				
			await contract.approve(tId);
			await contract.connect(owner2).approve(tId);
		})
		it("execute txExist", async()=>{
			await expect(contract.execute(tId+1)).to.be.reverted
		})
		it("execute success", async()=>{
			await contract.contribute({value:oneEth})
			expect(await contract.execute(tId)).to.changeEtherBalances([contractAddress, addr1], [-oneEth, oneEth])
		})
		it("execute failure", async()=>{
			await expect(contract.execute(tId)).to.be.revertedWith("Error: transaction failed")
		})
		it("execute failure, approvals <required", async()=>{
			await contract.submit(addr1.address, oneEth, "0x")				
			await contract.contribute({value:oneEth})
			await expect( contract.execute(tId+1)).to.be.revertedWith("Error: approvals < required ");
		})
	})
	describe("revoke", ()=>{
		let tId=0;
		beforeEach("submit and approve", async()=>{
			await contract.submit(addr1.address, oneEth, "0x")				
			await contract.contribute({value:oneEth})
			await contract.approve(tId);
		})	
		it("revoke success", async()=>{
			await contract.connect(owner2).approve(tId);
			expect(contract.revoke(tId)).to.emit(contract, "Revoke")
		})
		it("revoke fail already approved", async()=>{
			await expect(contract.connect(owner2).revoke(tId)).to.be.revertedWith("Error: transaction is not approved");	
		})
	})
})
