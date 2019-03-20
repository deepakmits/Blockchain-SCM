
# Supply chain & data auditing

This repository containts an Ethereum DApp that demonstrates a Supply Chain flow between a Manufacturer, Retailer and Consumer. The user story is similar to any commonly used supply chain process. A Manufacturer has a unique ID, Name, Location etc who procures , creates and sells luxury bags to Retailer, who receives and displays these bags and sells to Consumer, who sees those bags and purchases these bags from Retailer. Various Actors, Sequence flows , Activity diagrams and State transition diagrams are there in UMLDiagrams-LuxuryBags-SCM folder.

The DApp User Interface when running should look like...

![truffle test](SCM/images/ProductOverview.png)

![truffle test](SCM/images/ManufacturerDetails.png)

![truffle test](SCM/images/ProductDetails.png)

![truffle test](SCM/images/Transactions.png)


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Please make sure you've already installed ganache-cli, Truffle and enabled MetaMask extension in your browser.

### Installing

A step by step series of examples that tell you have to get a development env running

Clone this repository:

```
git clone https://github.com/udacity/nd1309/tree/master/course-5/project-6
```

Change directory to ```project-6``` folder and install all requisite npm packages (as listed in ```package.json```):

```
cd project-6
npm install
```

Launch Ganache:

```
ganache-cli -m "spirit supply whale amount human item harsh scare congress discover talent hamster"
```

Your terminal should look something like this:

![truffle test](SCM/images/TruffleDevelop.png)

In a separate terminal window, Compile smart contracts:

```
truffle compile
```

Your terminal should look something like this:

![truffle test](SCM/images/TruffleCompile.png)

This will create the smart contract artifacts in folder ```build\contracts```.

Migrate smart contracts to the locally running blockchain, ganache-cli:

```
truffle migrate
```

Your terminal should look something like this:

![truffle test](SCM/images/TruffleMigrate.png)

Test smart contracts:

```
truffle test
```

All 10 tests should pass.

![truffle test](SCM/images/TruffleTest.png)

In a separate terminal window, launch the DApp:

```
npm run dev
```

## Migration to Rinkeby - 
![truffle test](SCM/images/MigrateRinkeby.png)

## Contract Address on Rinkeby -
https://rinkeby.etherscan.io/tx/0x04323d06b5677acc60f0f8fc63d99439511523b88b24011a26e26fc1629ed10e
![truffle test](SCM/images/Etherscan.png)


## Built With

* [Ethereum](https://www.ethereum.org/) - Ethereum is a decentralized platform that runs smart contracts
* [IPFS](https://ipfs.io/) - IPFS is the Distributed Web | A peer-to-peer hypermedia protocol
to make the web faster, safer, and more open. This has not been used.
* [Truffle Framework](http://truffleframework.com/) - Truffle is the most popular development framework for Ethereum with a mission to make your life a whole lot easier.




