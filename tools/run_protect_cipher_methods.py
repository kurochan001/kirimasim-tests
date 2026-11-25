#!/usr/bin/env python3
"""Compare protect data_method requests with native output and independent CBC decoding."""

import argparse
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-cipher-methods"
CHECKER = "tools/run_protect_cipher_methods.py"
NETTLE_HELPER = "tools/protect_nettle_cbc.c"
CASE = "ch34/test_protect_data_method_cipher_selection"
CASES = {CASE: "first=93 second=93 control=a5"}
REQUIRED = "des-cbc"
METHOD_LINE = b'`pragma protect data_method = "des-cbc"'


@dataclass(frozen=True)
class Cipher:
    key_bytes: int
    block_bytes: int
    openssl: str | None = None
    legacy: bool = False


CIPHERS = {
    "des-cbc": Cipher(8, 8, "des-cbc", legacy=True),
    "3des-cbc": Cipher(24, 8, "des-ede3-cbc"),
    "aes128-cbc": Cipher(16, 16, "aes-128-cbc"),
    "aes192-cbc": Cipher(24, 16, "aes-192-cbc"),
    "aes256-cbc": Cipher(32, 16, "aes-256-cbc"),
    "blowfish-cbc": Cipher(16, 8, "bf-cbc", legacy=True),
    "twofish128-cbc": Cipher(16, 16),
    "twofish192-cbc": Cipher(24, 16),
    "twofish256-cbc": Cipher(32, 16),
    "serpent128-cbc": Cipher(16, 16),
    "serpent192-cbc": Cipher(24, 16),
    "serpent256-cbc": Cipher(32, 16),
    "cast128-cbc": Cipher(16, 8, "cast5-cbc", legacy=True),
}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, NETTLE_HELPER, protect.CHECKER, "tools/run_slang.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def cbc(openssl: str, nettle: Path, method: str, operation: str,
        key: bytes, iv: bytes, body: bytes) -> bytes:
    cipher = CIPHERS[method]
    if len(key) != cipher.key_bytes or len(iv) != cipher.block_bytes or len(body) % cipher.block_bytes:
        raise ValueError("unexpected fixture key, IV or ciphertext size")
    if cipher.openssl is None:
        return protect.invoke([str(nettle), method.removesuffix("-cbc"), operation], key + iv + body)
    providers = ["-provider", "default", "-provider", "legacy"] if cipher.legacy else []
    return protect.invoke([openssl, "enc", operation, "-" + cipher.openssl, *providers,
                           "-K", key.hex(), "-iv", iv.hex(), "-nopad", "-nosalt"], body)


def body_matches(expected: bytes, recovered: bytes, block_bytes: int) -> bool:
    if protect.keeps_body(expected, recovered):
        return True
    padding = recovered[-1] if recovered else 0
    return (0 < padding <= block_bytes and recovered.endswith(bytes([padding]) * padding)
            and protect.keeps_body(expected, recovered[:-padding]))


def reference_control(openssl: str, nettle: Path, method: str, expected: bytes) -> bool:
    cipher = CIPHERS[method]
    key = bytes(range(cipher.key_bytes))
    iv = bytes(range(cipher.block_bytes))
    padding = cipher.block_bytes - len(expected) % cipher.block_bytes
    plaintext = expected + bytes([padding]) * padding
    encrypted = cbc(openssl, nettle, method, "-e", key, iv, plaintext)
    recovered = cbc(openssl, nettle, method, "-d", key, iv, encrypted)
    changed_iv = bytes([iv[0] ^ 1]) + iv[1:]
    changed = cbc(openssl, nettle, method, "-d", key, changed_iv, encrypted)
    return (len(encrypted) == len(plaintext)
            and body_matches(expected, recovered, cipher.block_bytes)
            and not body_matches(expected, changed, cipher.block_bytes))


def recover_body(openssl: str, nettle: Path, private: Path, method: str,
                 envelope: bytes) -> tuple[bytes, bytes]:
    blocks = protect.parse_blocks(envelope)
    session_key = protect.unwrap_session_key(openssl, private, blocks[b"key_block"])
    payload = blocks[b"data_block"].decoded
    block_bytes = CIPHERS[method].block_bytes
    iv, ciphertext = payload[:block_bytes], payload[block_bytes:]
    if not ciphertext:
        raise ValueError("missing ciphertext after the IV")
    return cbc(openssl, nettle, method, "-d", session_key, iv, ciphertext), iv


def rejected_method(method: str, returncode: int, diagnostic: bytes, *, required: bool | None = None) -> str:
    if required is None:
        required = method == REQUIRED
    if required or returncode <= 0:
        return "encryptor_error"
    pattern = rb"\b(?:unsupported|not supported|unimplemented|unknown (?:cipher|algorithm|digest))\b"
    method_pattern = rb"(?<![\w-])" + re.escape(method.encode()) + rb"(?![\w-])"
    for line in diagnostic.lower().splitlines():
        if re.search(method_pattern, line) and re.search(pattern, line):
            return "unsupported_optional_method"
    return "encryptor_error"


def inspect_method(openssl: str, nettle: Path, private: Path, requested: str,
                   encrypted: bytes, expected: tuple[bytes, ...]) -> tuple[dict, list[bytes]]:
    result = {"outcome": "invalid_envelope", "emitted": [], "recovered_bodies": 0}
    try:
        output = protect.split(encrypted, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
    except ValueError:
        return result, []
    if len(output.bodies) != len(expected):
        return result, []

    emitted = [protect.fields(envelope).get(b"data_method", b"").decode("ascii", errors="replace")
               for envelope in output.bodies]
    ivs = []
    for envelope, body, method in zip(output.bodies, expected, emitted):
        if method not in CIPHERS:
            continue
        try:
            clear, iv = recover_body(openssl, nettle, private, method, envelope)
        except (ValueError, KeyError, subprocess.TimeoutExpired):
            continue
        if body_matches(body, clear, CIPHERS[method].block_bytes):
            result["recovered_bodies"] += 1
            ivs.append(iv)

    result["emitted"] = emitted
    if not all(emitted):
        result["outcome"] = "missing_method"
    elif any(method != requested for method in emitted):
        result["outcome"] = "substituted_method"
    elif result["recovered_bodies"] != len(expected):
        result["outcome"] = "body_not_verified"
    else:
        result["outcome"] = "pass"
    result["distinct_recovered_ivs"] = len(set(ivs))
    return result, ivs


def run_encryptor(python: str, variant: Path, public: Path, output: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        [python, "-I", "-c", "from hdl_encrypt import main; main()", str(variant),
         "-k", str(public), "-o", str(output), "--owner", "Qualification", "--keyname", "fixture-only"],
        capture_output=True, timeout=60,
    )


def compare_methods(python: str, openssl: str, nettle: Path, fixture: Path, work: Path) -> dict:
    source = fixture.read_bytes()
    if source.count(METHOD_LINE) != 1:
        raise ValueError("expected one data_method request")
    ranges = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    expected = tuple(part.strip(b"\r\n") for part in ranges.bodies)
    if len(expected) != 2 or not expected[0] or expected[0] != expected[1]:
        raise ValueError("expected two identical nonempty protected bodies")
    private, public = protect.exchange_key(openssl, work, "fixture")
    variant, output = work / "cipher.sv", work / "protected.sv"
    observations = {}
    observed_ivs = []
    for method in CIPHERS:
        variant.write_bytes(source.replace(METHOD_LINE, b'`pragma protect data_method = "' + method.encode() + b'"'))
        try:
            control = reference_control(openssl, nettle, method, expected[0])
        except (ValueError, subprocess.TimeoutExpired):
            control = False
        observations[method] = {"required": method == REQUIRED, "reference_control": control}
        output.unlink(missing_ok=True)
        try:
            native = run_encryptor(python, variant, public, output)
        except subprocess.TimeoutExpired:
            observations[method]["outcome"] = "encryptor_timeout"
            continue
        if native.returncode != 0:
            outcome = rejected_method(method, native.returncode, native.stderr + native.stdout)
            observations[method].update(outcome=outcome, exit=native.returncode)
            continue
        encrypted = output.read_bytes() if output.is_file() else b""
        result, ivs = inspect_method(openssl, nettle, private, method, encrypted, expected)
        observations[method].update(result)
        observed_ivs.extend(ivs)
    return {
        "checks": observations,
        "recovered_cbc_payloads": len(observed_ivs),
        "distinct_recovered_ivs": len(set(observed_ivs)),
    }


def build_nettle(prefix: Path, executable: Path) -> str:
    prefix = prefix.resolve()
    lib = prefix / "lib"
    subprocess.run([os.environ.get("CC", "cc"), "-Wall", "-Wextra", "-Werror",
                    "-I" + str(prefix / "include"), "-L" + str(lib),
                    f"-Wl,-rpath,{lib}", str(suite_results.ROOT / NETTLE_HELPER),
                    "-lnettle", "-o", str(executable)], timeout=60, check=True)
    return protect.invoke([str(executable), "--version"]).decode().strip()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl", help="OpenSSL with the default and legacy providers")
    parser.add_argument("--nettle-prefix", type=Path, required=True, help="Nettle headers and library prefix")
    parser.add_argument("--json", required=True, type=Path, help="write the qualification results")
    args = parser.parse_args()

    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None:
        parser.error("Python or OpenSSL is unavailable")
    fixture = suite_results.ROOT / "tests" / (CASE + ".sv")
    if suite_results.header(fixture).get("expected_stdout") != CASES[CASE]:
        parser.error("unexpected control output")
    checker, fingerprint, tool = checker_digest(), suite_results.input_digest(fixture), protect.tool_info(python)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        nettle = work / "nettle-cbc"
        nettle_version = build_nettle(args.nettle_prefix, nettle)
        result = compare_methods(python, openssl, nettle, fixture, work)
    if (checker != checker_digest() or fingerprint != suite_results.input_digest(fixture)
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")

    run_slang.write(args.json, {"profile": PROFILE, "encryptor": tool,
                               "openssl": protect.invoke([openssl, "version"]).decode().strip(),
                               "nettle": nettle_version,
                               "checker_sha256": checker,
                               "tests": {CASE: {"inputs_sha256": fingerprint, **result}}})
    for method, details in result["checks"].items():
        print(f"{method}: {details['outcome']} (reference control: {details['reference_control']})")
    checks = result["checks"].values()
    return int(any(not row["reference_control"] or row["outcome"] not in ("pass", "unsupported_optional_method")
                   for row in checks) or result["recovered_cbc_payloads"] != result["distinct_recovered_ivs"])


if __name__ == "__main__":
    raise SystemExit(main())
