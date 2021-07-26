# @version ^0.2.0

# Super creative idea of having pools where people can go out and "pool" funds together and other's can borrow them for a fee
# How are we different, we're not this is just for practice. For now atleast

# Want to have the option for delegatecall, in order to change rates/percentages periodically. Based on community vote
# Pools will normally consist of stable coins for simplicity

# Will use interfaces in order to have separate smart contracts interacting with each other
# Will write extensive tests for all functions, even simple view functions

# Have to go back and look at code from yearn, aave and other defi projects for inspiration regarding fees and such

# I will also add time lockups for people who pool ether. It will vary on how much they pool. The more they pool the shorter the lockup

# for the sake of adding an interface later
admin: address

# members must pay before they can join any pool
# This is to verify that pool members are commited
protocol_members: HashMap[address, String[50]]

# Address will be pool owner, String[50] is Pool name(might change into bytes32), and uint256 is amount that's been pooled
# Only pool owner can destroy the pool, it will return the rightful amount to everyone who participates in pool
pool_list: HashMap[address, HashMap[String[50], uint256]]

# If you've pooled your money into one of the available pools, you can view that amount here
# It will be tracked here how much money you have pooled, by individual pool
# address of pool owner, string name of pool and amount that is being added on your behalf.
user_to_pooled_ether: HashMap[address, HashMap[String[50], uint256]]

@external
def __init__():
    self.admin = msg.sender

@external
@payable
def joinProtocol(username: String[50]) -> bool:
    assert msg.value >= 1, "To join you must pay atleast 1 ether"
    assert self.protocol_members[msg.sender] == ''
    self.protocol_members[msg.sender] = username
    return True

@external
@payable
def createPool(pool_name: String[50], amount: uint256) -> bool:
    assert msg.value >= 1 + amount, "To create a pool you must pay atleast 1 ether"
    assert self.pool_list[msg.sender][pool_name] == 0, "Pool has already been created"
    # amount refers to how much they want to place in pool to start
    self.pool_list[msg.sender][pool_name] += amount
    # This tracks how much they have staked in the pool
    self.user_to_pooled_ether[msg.sender][pool_name] += amount
    return True

@external
@payable
def joinPool(pool_name: String[50], pool_owner: address, amount: uint256) -> bool:
    assert msg.value >= amount, "The amount has to correspond with what you are pooling"
    assert self.protocol_members[msg.sender] != '', "You must be a member of the protocol to participate in a pool"
    assert self.user_to_pooled_ether[msg.sender][pool_name] == 0, "You have already joinded this pool"
    # Increase the amount of the entire pool
    self.pool_list[pool_owner][pool_name] += amount
    self.user_to_pooled_ether[msg.sender][pool_name] += amount
    return True
