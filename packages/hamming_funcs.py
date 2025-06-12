import math

def hamming_address_width(data_width: int) -> int:
    """
    Calculate the number of address bits required for Hamming encoding.
    
    This assumes an extended Hamming code (with one extra bit for total parity).
    For example, 27 bits of data need 7 parity bits, taking total size to 34,
    requiring 6 address bits instead of 5.
    """
    addr = math.ceil(math.log2(data_width))
    parity = addr + 1
    max_val = 2 ** addr
    min_val = max_val - parity

    if data_width > min_val:
        return addr + 1
    else:
        return addr