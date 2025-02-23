# Fund Me

This is a basic solidity smart contract meant for learning purposes. Users can 'fund me' through the smart contract; sending eth to the smart contract that the creator can withdraw at any time. 

In the spirit of community, I share this project with detailed comments that can help any newbie get started creating smart contracts with solidity.

## About

The project is part of a blockchain developer program by Cyfrin-Updraft; where we learn how to harness the power of the ethereum blockchain to build powerful decentralized applications that empower the users through their decentralized nature. The Fund-Me project is the first complete project with tests and an actual usecase. With it, you can start a fundraiser for your new business idea or any other cause you wish fundraise for.

## Getting Started

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


### Quickstart

```
git clone https://github.com/kennjr/foundry-fund-me.git
cd foundry-fund-me
make
```

## Usage

### Deploy

```
forge script script/DeployFundMe.s.sol
```

### Testing

We talk about 4 test tiers in the video. 

1. Unit
2. Integration
3. Forked
4. Staging

This repo we cover #1 and #3. 


```
forge test
```

or 

```
// Only run test functions matching the specified regex pattern.

forge test --match-test testFunctionName

or

forge test --mt testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

#### Test Coverage

Find out how much of the code has been covered by the written tests with the following command.

```
forge coverage
```

### Local zkSync 

The instructions here will allow you to work with this repo on zkSync.

#### (Additional) Requirements 

In addition to the requirements above, you'll need:
- [foundry-zksync](https://github.com/matter-labs/foundry-zksync)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.0.2 (816e00b 2023-03-16T00:05:26.396218Z)`. 
- [npx & npm](https://docs.npmjs.com/cli/v10/commands/npm-install)
  - You'll know you did it right if you can run `npm --version` and you see a response like `7.24.0` and `npx --version` and you see a response like `8.1.0`.

## Known Issues

There's one issue that you might encounter when running the project; the ```testUserCanFund()``` test in the integration tests category fails, I haven't yet figured out what the problem might be, I get an `OutOfFunds` error yet I allocate 100 eth to the account right before the transaction. I welcome any solution to this problem, simply make a PR and I'll check it out.

## Support and contact details

If you run into any other issues while interacting with the application, you can contribute to it by: reporting the issue and probably suggest a fix for it.

## Future

There aren't any plans to further develop this application. Updates will be minimal and primarily bug fixes as I continue to learn and improve my smart contract development skills.

### License

This software is publicly available under the [MIT](LICENSE) license.