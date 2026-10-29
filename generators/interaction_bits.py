"""Small bit-string helpers for independently modeled interaction tests."""


def pattern(width: int, value: str) -> str:
    bits = list(f"{(1 << (width - 1)) | (1 << (width // 2)) | 1:0{width}b}")
    if value != "known":
        bits[0] = bits[-1] = value
    return "".join(bits)


def resize(bits: str, width: int, signed: bool) -> str:
    if width <= 0:
        raise ValueError("a packed value needs a positive width")
    if width <= len(bits):
        return bits[-width:]
    return (bits[0] if signed else "0") * (width - len(bits)) + bits


def two_state(bits: str) -> str:
    return bits.replace("x", "0").replace("z", "0")
