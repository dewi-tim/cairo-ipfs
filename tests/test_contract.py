"""contract.cairo test file."""
import os
import pytest
from starkware.starknet.testing.starknet import Starknet
from util import output2cid,cid2input


## todo refactor

# The path to the contract source code.
IPFS_CONTRACT_FILE = os.path.join("contracts", "IPFS_updateable.cairo")
KECCAK_CONTRACT_FILE = os.path.join("contracts", "keccak_contract.cairo")

# Precomputed CIDs
with open('data/old_root_cid','rb') as f:
    INIT_ROOT = f.read()
with open('data/new_state_cid','rb') as f:
    STATE = f.read()
with open('data/new_root_cid','rb') as f:
    ROOT = f.read()


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_deployment():
    """Test stored root CID can be extracted from deployed contract"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()
    # Deploy contracts
    keccak = await starknet.deploy(
        source=KECCAK_CONTRACT_FILE,
    )
    constructor_calldata = [
        keccak.contract_address,
        *cid2input(INIT_ROOT)
    ]
    ipfs = await starknet.deploy(
        source=IPFS_CONTRACT_FILE,
        constructor_calldata=constructor_calldata
    )
    # Check reported root CID of deployed contract
    execution_info = await ipfs.get_root().call()
    reported_cid = output2cid(execution_info.result.root)
    assert reported_cid.encode('base32') == INIT_ROOT

@pytest.mark.asyncio  
async def test_update():
    """Test updated root CID matches precomputed ipfs dag api output"""
    starknet = await Starknet.empty()
    # Deploy contracts
    keccak = await starknet.deploy(
        source=KECCAK_CONTRACT_FILE,
    )
    constructor_calldata = [
        keccak.contract_address,
        *cid2input(INIT_ROOT)
    ]
    ipfs = await starknet.deploy(
        source=IPFS_CONTRACT_FILE,
        constructor_calldata=constructor_calldata
    )
    # Update root with state
    await ipfs.update_root(cid2input(STATE)).invoke()
    # Check reported root against expected
    execution_info = await ipfs.get_root().call()
    reported_cid = output2cid(execution_info.result.root)
    assert reported_cid.encode('base32') == ROOT
