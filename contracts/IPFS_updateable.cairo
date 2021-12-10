# Imports
%lang starknet
%builtins pedersen range_check bitwise
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin,HashBuiltin
from starkware.cairo.common.bitwise import bitwise_xor,bitwise_and
from starkware.cairo.common.registers import get_fp_and_pc

# Constants
## Defines the fixed parts of the DAG-CBOR encoding of { prev:CID(000000000000000000000000000), state:CID(00000000000000000000000000000000)}
const CBOR0 = 3087347722646217890 # b'\xa2dprev\xd8*'
const CBOR1 = 9037371416782168    # b'X%\x00\x01q\x1b \x00'
const CBOR5 = 7277816997830721536 #b'\x00\x00\x00\x00\x00\x00\x00e'
const CBOR6 = 6353128154615346291  #b'state\xd8*X'
const CBOR7 = 35302232096805       # b'%\x00\x01q\x1b \x00\x00'
## Defines multipliers/divisors for shifts in preprocessor
const SHIFT6B = (2**8)**6
const SHIFT2B = (2**8)**2
const SHIFT7B = (2**8)**7
const SHIFT1B = (2**8)**1
## Defines bitmasks for preprocesser
const UPPER6B_MASK = 18446744073709486080
const LOWER2B_MASK = 65535            
const UPPER7B_MASK = 18446744073709551360
const LOWER1B_MASK = 255
## Flags
const UPPER = 1
const LOWER = 0

# Structs
struct MaskShift:
    member mask : felt
    member shift : felt
end

struct Params:
    member lower : MaskShift
    member upper : MaskShift
end

# Interfaces
@contract_interface
namespace IKeccakContract:
    func compute_keccak(
        input_len : felt, input : felt*, n_bytes : felt) -> (
        res0 : felt, res1 : felt, res2 : felt, res3 : felt):
    end
end

# Storage vars
@storage_var
func root() -> (hash : (felt,felt,felt,felt)):
end

@storage_var
func keccak_address() -> (address : felt):
end
# Constructor
# # Takes as input the keccak-256 hash of DAG-CBOR encoded initial state, encoded as 4 x 64bit LE words
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address :felt,
        init_root_hash : (felt,felt,felt,felt)):
    root.write(value=init_root_hash)
    keccak_address.write(value=address)
    return ()
end

# External functions
## Getter for stored root CID hash
@external
func get_root{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (root: (felt,felt,felt,felt)):
    let (root_hash) = root.read()
    return (root_hash)
end
## Takes as input the keccak-256 hash of DAG-CBOR encoded new state, encoded as 4 x 64bit LE words
@external
func update_root{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,bitwise_ptr : BitwiseBuiltin*}(
        hash : (felt,felt,felt,felt)) -> (root : (felt,felt,felt,felt)): 
    alloc_locals
    let (input) = alloc()
    assert input[0] = CBOR0
    let (data) = alloc()
    let (root_hash) = root.read()
    assert data[0] = root_hash[0]
    assert data[1] = root_hash[1]
    assert data[2] = root_hash[2]
    assert data[3] = root_hash[3]
    let (res) = alloc()
    let (__fp__, _) = get_fp_and_pc()
    local params : Params = Params(
        lower=MaskShift(mask=LOWER1B_MASK,shift=SHIFT7B), #first take lower 1B, shift up by 7B
        upper=MaskShift(mask=UPPER7B_MASK,shift=SHIFT1B) #then take upper 7B, shift down by 1B)
    )
    preprocess(res_lower=CBOR1,data_len=4,data=data,res=res,seg=LOWER,pos=0,params=&params)
    assert input[1] = res[0]
    assert input[2] = res[1]
    assert input[3] = res[2]
    assert input[4] = res[3]
    let (merged) = bitwise_xor(res[4],CBOR5)
    assert input[5] = merged
    assert input[6] = CBOR6
    let (data) = alloc()
    assert data[0] = hash[0]
    assert data[1] = hash[1]
    assert data[2] = hash[2]
    assert data[3] = hash[3]
    let (res) = alloc()
    let (__fp__, _) = get_fp_and_pc()
    local params : Params = Params(
        lower=MaskShift(mask=LOWER2B_MASK,shift=SHIFT6B), #first take lower 1B, shift up by 7B
        upper=MaskShift(mask=UPPER6B_MASK,shift=SHIFT2B) #then take upper 7B, shift down by 1B)
    )
    preprocess(res_lower=CBOR7,data_len=4,data=data,res=res,seg=LOWER,pos=0,params=&params)
    assert input[7] = res[0]
    assert input[8] = res[1]
    assert input[9] = res[2]
    assert input[10] = res[3]
    assert input[11] = res[4]
    let (contract_address) = keccak_address.read() 
    let (hash0,hash1,hash2,hash3) = IKeccakContract.compute_keccak(
       contract_address=contract_address,
       input_len=12,
       input=input,
       n_bytes=94)
    root.write(value=(hash0,hash1,hash2,hash3))
    return ((hash0,hash1,hash2,hash3))
end

# Helper functions
## Takes array of 64bit LE words `data`, writes `data` shifted by log_2**8(`params.lower.shift`) bytes to array `res`
## TODO: reimplement with jumps
func preprocess{bitwise_ptr : BitwiseBuiltin*}(res_lower : felt, data_len : felt, data : felt*, res : felt*, seg : felt, pos : felt, params : Params*):
    if pos == data_len:
        assert res[pos] = res_lower
        return()
    end
    if seg == LOWER:
        let (lower) =  bitwise_and(params.lower.mask,data[pos])
        let shifted = lower * params.lower.shift
        let (merged) = bitwise_xor(res_lower,shifted)
        assert res[pos] = merged
        preprocess(res_lower=0,data_len=data_len,data=data,res=res,seg=UPPER,pos=pos,params=params)
        return()
    end
    # UPPER
    if seg == UPPER:
        let (upper) = bitwise_and(params.upper.mask,data[pos])
        let shifted = upper/params.upper.shift
        preprocess(res_lower=shifted,data_len=data_len,data=data,res=res,seg=LOWER,pos=pos+1,params=params)
        return()
    end
    return()
end
