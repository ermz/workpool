# @version ^0.2.0

# for the sake of adding an interface later
admin: address

# members must pay before they can join any pool
# This is to verify that pool members are commited
protocol_members: HashMap[address, String[50]]

# Address will be pool owner, String[50] is Pool name(might change into bytes32), and uint256 is amount that's been pooled
# Only pool owner can destroy the pool, it will return the rightful amount to everyone who participates in pool
pool_list: HashMap[address, HashMap[String[50], uint256]]

# Need to check for pools with duplicate names

# If you've pooled your money into one of the available pools, you can view that amount here
# It will be tracked here how much money you have pooled, by individual pool
# address of pool owner, string name of pool and amount that is being added on your behalf.
user_to_pooled_ether: HashMap[address, HashMap[String[50], uint256]]

pool_time: HashMap[String[50], uint256]
pool_end_time: HashMap[String[50], uint256]

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
def createPool(pool_name: String[50], amount: uint256, time: uint256) -> bool:
    assert msg.value >= 1 + amount, "To create a pool you must pay atleast 1 ether"
    assert self.pool_list[msg.sender][pool_name] == 0, "Pool has already been created"
    # amount refers to how much they want to place in pool to start
    self.pool_list[msg.sender][pool_name] += amount
    # This tracks how much they have staked in the pool
    self.user_to_pooled_ether[msg.sender][pool_name] += amount
    self.pool_time[pool_name] = time
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

@external
def startPool(pool_name: String[50]):
    assert self.pool_list[msg.sender][pool_name] > 0, "This pool either has no funds or you are not the pool owner"
    assert self.pool_time[pool_name] > 0, "Pool time can't be 0"
    assert self.pool_end_time[pool_name] == 0, "This pool has already started"
    self.pool_end_time[pool_name] = (block.timestamp + self.pool_time[pool_name])

@external
def workLoans(pool_name: String[50], amount: uint256) -> bool:
    assert self.pool_list[msg.sender][pool_name] > amount, "You are either not the owner or you don't have enough to make transaction"
    assert self.pool_end_time[pool_name] < block.timestamp, "The time has expired for this pool"
    original_contract_bal: uint256 = self.balance
    # Make calls to interfaces here where the workloans(flashloans)
    # will take place and make assertions at the end that all the money
    # or tokens that were used are still there at the end
    assert original_contract_bal == self.balance
    return True

@external
def withdrawFunds(pool_name: String[50]) -> bool:
    assert self.pool_end_time[pool_name] > block.timestamp, "The pool is ongoing until end time is reached"
    assert self.user_to_pooled_ether[msg.sender][pool_name] > 0, "You've nothing left to withdraw"
    send(msg.sender, self.user_to_pooled_ether[msg.sender][pool_name])
    return True




# Ok so I'm changing up the entire idea of this project
# I'm going to do what people usually do in Latin American homes
# The pool creator need money, they will create a pool where everyone(friends/family/anyone) can ship in
# The pool creator will now have access to those funds and can make flashloans for a particular amount of time
# The pool creator will have to pay the dividents immediately of everyone who joins his pool
# Then that user can make flashloans transactions during a period of time
# This will allow him to make flashloan transactions without having all the money up front
# The benefit compared to AAVE, is that the % you have to pay is lower
# It will be a fixed amount for a period of time + you would have funds to use for period of time
# You wouldn't have to worry about changing prices daily
# It's almost a gofundme for a friend/family w/out having to trust anyone directly

# have to create a lockup period
# only when enough time has passed will they be able to access those funds

# Biggest benefit for lender, They know how much they'll make immediately
# Biggest benefit for borrower, They'll know how much they'll have to pay to use funds in flashloans
# The idea is that this is for helping someone, not a money maker


