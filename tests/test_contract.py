"""contract.cairo test file."""
import os
import pytest
from starkware.starknet.testing.starknet import Starknet

# util imports
from multihash import encode
from cid import make_cid
import struct
# CID prefix = b'\x00\x00\x01q\x1b '
# Keccak input: [b'\xa2estate\xd8']     [b'*X%'<CID1[0]>] [<CID1[1:9]>               ]   ... [<CID1[30:37]>b'd'] [b'prev\xd8*X%']        [<CID2[0:8]>       ] ... [<CID2[34:37]>] 102 bytes
# Keccak input: [b'\xa2estate\xd8']     [b'*X%' b'\x00\x00\x01q\x1b' ] [b' '<H1[0:7]>]   ...     [<H1[25:32]>b'd']   [b'prev\xd8*X%']        [b'\x00\x00\x01q\x1b '<H[0:2]>] ... [<H[29:32]>] 102 bytes
#               8391155497128847778  10792990157403233        538669313 ^ (H1[0:4]                7236281193744826368     6353128218956886623      35302232096806                  

def hash2cid(hash,*encode_params):
    mh = encode(hash,'keccak-256')
    cid = make_cid(1,'dag-cbor',mh)
    return cid

def cid2input(cid_str):
    cid = make_cid(cid_str)
    hash_bytes = cid.encode('identity')[-32:]
    return struct.unpack('<QQQQ',hash_bytes)

def output2cid(hash_ints):
    hash_bytes = struct.pack("<QQQQ",*hash_ints)
    return hash2cid(hash_bytes,'identity')

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
async def test_increase_balance():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()
    # Deploy the contracts
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
    calculated_root = await ipfs.u
    


    # Invoke increase_balance() twice.
    await contract.increase_balance(amount=10).invoke()
    await contract.increase_balance(amount=20).invoke()

    # Check the result of get_balance().
    execution_info = await contract.get_balance().call()
    assert execution_info.result == (30,)
