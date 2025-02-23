# we use a make file to simplify running commands on the terminal, rather than type out a rather long command we can create an alias for it in this file 
# and use that whenever we want to run that specific command. Here are some examples:

# the line below will let us get access to our environment var.s
-include .env

# we use the ':;' syntax to make the command a one liner
build:; forge build

compile:; forge compile

deploy:; forge script script/FundMe.s.sol:FundMeScript --rpc-url $(LOCAL_CHAIN_URL) --account zero --sender $(LOCAL_CHAIN_SENDER_ZERO) --broadcast -vvv

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url $(LOCAL_CHAIN_URL)  --account zero --sender $(LOCAL_CHAIN_SENDER_ZERO) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

fund:
	@forge script script/Interactions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe $(NETWORK_ARGS)