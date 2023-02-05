// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// To complete this challenge, you have to 
// 1. claim ownership of the contract 
// 2. withdraw all the funds(eth)


/*Solution

-To claim the ownership of the contract, we must contribute first by calling the contribute function
=> await contract.contribute(toWei("0.00001")) Note that contribution needs to be < 0.001 ether

The if statement in the contribute function specifies that we can only become the owner if our contributions > contribution[owner]
See that in the constructor function, the owner's contributions is set to 1000 ether
So who is the owner at this point? we must understand the constructor function first

Constructors are functions that execute once in the lifecycle of a smart contract: It is execute once a smart contract is deployed.
Therefore ethernaut is the owner of the smart contract once it was deployed and their contributions was set to 1000 ether
We cannot claim ownership of the smart contract because our contributions was less that 1000 ether.

Now look further to the last function 
The receive function: we can become the owner of the contract by calling the receive function. 
The receive function requires that we send some eth > 0 and our contributions must be > 0
Now understand that the receive function is a fallback function and fallback functions are executed when a contract is called without any data
I suggest you read more about callback function

To execute the receive function, we use the send() function
=> await contract.send(toWei("0.0001")) 
we must send eth > 0 because the receive function requires it. Also, and we already have contributions > 0
This means we have satisfied all conditions and we are now the new owner of the smart contract.

Next step is to simply withdraw all the funds
The withdraw function can only be called by an owner: The modifier "onlyOwner" takes care of that
we simply withdraw all the funds by...
=> await contract.withdraw()

And game over!! 
Challenge passed!!


*/

contract Fallback {

  mapping(address => uint) public contributions;
  address public owner;

  constructor() {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether); // sets ethernaut as the owner when the smart contract is deployed
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether); // Requires that we contribute eth not more that 0.001 eth
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) { 
      owner = msg.sender; // We cannot become the owner after calling the contribute function because our contributions < 1000 ether
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    payable(owner).transfer(address(this).balance); // Only an owner can call the withdraw function
  }

  receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0); //Requires that we must send eth > 0. Also, and we already have contributions > 0
    owner = msg.sender; // we automatically become the owner of the smart contract
  }
}