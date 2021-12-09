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

def output2cid(output_str):
    hash_ints = [int(x,0)for x in output_str.split()]
    hash_bytes = struct.pack("<QQQQ",*hash_ints)
    return hash2cid(hash_bytes,'identity')

