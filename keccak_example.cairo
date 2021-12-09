%builtins output range_check bitwise

from keccak import finalize_keccak, keccak
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

func main{output_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    local bitwise_ptr_start : BitwiseBuiltin* = bitwise_ptr
    let (local keccak_ptr : felt*) = alloc()
    let keccak_ptr_start = keccak_ptr

    # Compute keccak of "Hello world!".
    let (local input : felt*) = alloc()
    assert input[0] = %[ int.from_bytes(b'Hello wo', 'little') %]
    assert input[1] = %[ int.from_bytes(b'rld!', 'little') %]
    let (output) = keccak{keccak_ptr=keccak_ptr}(input, 12)
    %{
        input_str = 'Hello world!'
        output = ''.join(v.to_bytes(8, 'little').hex() for v in memory.get_range(ids.output, 4))
        print(f'Keccak of "{input_str}": {output}')
        from web3 import Web3
        assert '0x' + output == Web3.keccak(text=input_str).hex()
    %}
    assert output_ptr[0] = output[0]
    assert output_ptr[1] = output[1]
    assert output_ptr[2] = output[2]
    assert output_ptr[3] = output[3]
    let output_ptr = output_ptr + 4

    # Compute keccak of a short random string: "uzlbpiah".
    let (local input : felt*) = alloc()
    assert input[0] = %[ int.from_bytes(b'uzlbpiah', 'little') %]
    let (output) = keccak{keccak_ptr=keccak_ptr}(input, 8)
    %{
        input_str = 'uzlbpiah'
        output = ''.join(v.to_bytes(8, 'little').hex() for v in memory.get_range(ids.output, 4))
        print(f'Keccak of "{input_str}": {output}')
        assert '0x' + output == Web3.keccak(text=input_str).hex()
    %}
    assert output_ptr[0] = output[0]
    assert output_ptr[1] = output[1]
    assert output_ptr[2] = output[2]
    assert output_ptr[3] = output[3]
    let output_ptr = output_ptr + 4

    # Compute keccak of a long random string:
    #   x = "uzlbpiahgabzsvmfeixnkgckllvydhrawqlxblbwaiesgdyaonwcttdjelybogdyruqjjeca" +
    #       "xyzkbtgxmflkrzihjrmorulgffzqceebemlhjdhgzhamobnesgomqsy"
    let (local input : felt*) = alloc()
    assert input[0] = %[ int.from_bytes(b'uzlbpiah', 'little') %]
    assert input[1] = %[ int.from_bytes(b'gabzsvmf', 'little') %]
    assert input[2] = %[ int.from_bytes(b'eixnkgck', 'little') %]
    assert input[3] = %[ int.from_bytes(b'llvydhra', 'little') %]
    assert input[4] = %[ int.from_bytes(b'wqlxblbw', 'little') %]
    assert input[5] = %[ int.from_bytes(b'aiesgdya', 'little') %]
    assert input[6] = %[ int.from_bytes(b'onwcttdj', 'little') %]
    assert input[7] = %[ int.from_bytes(b'elybogdy', 'little') %]
    assert input[8] = %[ int.from_bytes(b'ruqjjeca', 'little') %]
    assert input[9] = %[ int.from_bytes(b'xyzkbtgx', 'little') %]
    assert input[10] = %[ int.from_bytes(b'mflkrzih', 'little') %]
    assert input[11] = %[ int.from_bytes(b'jrmorulg', 'little') %]
    assert input[12] = %[ int.from_bytes(b'ffzqceeb', 'little') %]
    assert input[13] = %[ int.from_bytes(b'emlhjdhg', 'little') %]
    assert input[14] = %[ int.from_bytes(b'zhamobne', 'little') %]
    assert input[15] = %[ int.from_bytes(b'sgomqsy', 'little') %]
    let (output) = keccak{keccak_ptr=keccak_ptr}(input, 127)
    %{
        input_str = 'uzlbpiahgabzsvmfeixnkgckllvydhrawqlxblbwaiesgdyaonwcttdjelybogdyruqjjeca' + \
            'xyzkbtgxmflkrzihjrmorulgffzqceebemlhjdhgzhamobnesgomqsy'
        output = ''.join(v.to_bytes(8, 'little').hex() for v in memory.get_range(ids.output, 4))
        print(f'Keccak of "{input_str}": {output}')
        assert '0x' + output == Web3.keccak(text=input_str).hex()
    %}
    assert output_ptr[0] = output[0]
    assert output_ptr[1] = output[1]
    assert output_ptr[2] = output[2]
    assert output_ptr[3] = output[3]
    let output_ptr = output_ptr + 4

    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr)

    %{
        # Print the number of used bitwise builtin instances.
        bitwise_start = ids.bitwise_ptr_start.address_
        print('Bitwise usage:', (ids.bitwise_ptr.address_ - bitwise_start) / 5)
    %}

    return ()
end
