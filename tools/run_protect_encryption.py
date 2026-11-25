#!/usr/bin/env python3
"""Inspect hdl-encrypt output using fixture-owned keys and the OpenSSL CLI."""

import argparse
import base64
import binascii
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_slang
import suite_results


PROFILE = "protect-encryption"
CHECKER = "tools/run_protect_encryption.py"
EXCHANGE_CASE = "ch34/test_protect_exchange_key_metadata_and_boundaries"
CASES = {
    "ch34/test_protect_encrypts_only_delimited_source_ranges": "protected values=17,29 clear=11",
    "ch34/test_protect_exports_author_fields_and_limits_encoded_lines": "protected values=41,73 clear=31",
    EXCHANGE_CASE: "first=a5 second=3c third=5d",
}
RECIPIENTS = (
    (b"Fixture East", b"assembly"),
    (b"Fixture West", b"assembly"),
    (b"Fixture East", b"backup"),
)
CIPHERS = {b"aes128-cbc": ("aes-128-cbc", 16), b"aes256-cbc": ("aes-256-cbc", 32)}
PRAGMA = rb"`pragma[ \t]+protect[ \t]+"
SOURCE_BEGIN = re.compile(rb"^" + PRAGMA + rb"begin[ \t]*(?=\r?$)", re.M)
SOURCE_END = re.compile(rb"^" + PRAGMA + rb"end[ \t]*(?=\r?$)", re.M)
OUTPUT_BEGIN = re.compile(rb"^" + PRAGMA + rb"begin_protected[ \t]*(?=\r?$)", re.M)
OUTPUT_END = re.compile(rb"^" + PRAGMA + rb"end_protected[ \t]*(?=\r?$)", re.M)
# hdl-encrypt 0.1.0 emits this line without begin_protected. Use it to recover
# independent observations from the payload while still failing boundary checks.
FALLBACK_BEGIN = re.compile(rb"^" + PRAGMA + rb"version[ \t]*=[ \t]*\d+[ \t]*(?=\r?$)", re.M)
DIRECTIVE = re.compile(rb"^[ \t]*" + PRAGMA + rb"([^\r\n]*)", re.M)
ATTRIBUTE = re.compile(rb'\b([a-z_]+)\s*=\s*(?:"([^"\r\n]*)"|(\d+))')
MODULE = re.compile(rb"^module encryption_fixture_(?:first|second)\b.*?^endmodule\b", re.M | re.S)
BLOCKS = (b"key_block", b"data_block")
EXPORTED = (b"author", b"author_info", b"comment")
CONTROLS = (b"data_method", b"encoding", b"key_method", b"key_keyowner", b"key_keyname")
PADDING = re.compile(rb"(?:\s|//[^\n]*(?:\n|$)|/\*.*?\*/)*", re.S)
ENVELOPE_CHECKS = (
    "body_preserved", "session_key", "aes256_identifier", "cbc_iv_prefix",
    "explicit_descriptors", "base64_representation", "ignored_input_byte_hint", "line_limit",
    "author_export", "author_info_export", "clear_comment", "comment_excluded", "agent_output",
)
LAYOUT_CHECKS = ("clear_preserved", "begin_output", "end_output", "begin_boundary",
                 "envelope_replacement")
ROLE_CHECKS = (
    "encryption_boundaries", "begin_decryption", "end_decryption",
    "body_ciphertext", "key_ciphertext", "key_owner", "key_name", "key_method",
    "body_method", "encoding", "author", "author_info", "comment",
    "encrypt_agent", "self_contained",
)


@dataclass(frozen=True)
class Block:
    lines: tuple[bytes, ...]
    decoded: bytes
    encoding: dict[bytes, bytes]
    preceding: bytes


@dataclass(frozen=True)
class Layout:
    clear: tuple[bytes, ...]
    bodies: tuple[bytes, ...]
    opened: tuple[bool, ...]


def attributes(directive: bytes) -> dict[bytes, bytes]:
    return {match[1]: match[2] if match[2] is not None else match[3]
            for match in ATTRIBUTE.finditer(directive)}


def fields(lines: bytes) -> dict[bytes, bytes]:
    result = {}
    for statement in DIRECTIVE.findall(lines):
        result.update(attributes(statement))
    return result


def split(source: bytes, openings: re.Pattern, closings: re.Pattern,
          fallback: re.Pattern | None = None) -> Layout:
    clear, bodies, opened = [], [], []
    cursor = 0
    for end in closings.finditer(source):
        candidates = list(openings.finditer(source, cursor, end.start()))
        explicit = bool(candidates)
        if not explicit and fallback is not None:
            candidates = list(fallback.finditer(source, cursor, end.start()))
        if len(candidates) != 1:
            raise ValueError("unpaired envelope boundaries")
        start = candidates[0]
        clear.append(source[cursor:start.start()])
        bodies.append(source[start.end():end.start()])
        opened.append(explicit)
        cursor = end.end()
    if openings.search(source, cursor):
        raise ValueError("unclosed envelope")
    clear.append(source[cursor:])
    return Layout(tuple(clear), tuple(bodies), tuple(opened))


def without_directives(text: bytes, names: tuple[bytes, ...]) -> bytes:
    directives = rb"(?:" + b"|".join(names) + rb")\s*="
    return re.sub(rb"^[ \t]*" + PRAGMA + directives + rb"[^\r\n]*(?:\r?\n|$)", b"", text, flags=re.M)


def decode_payload(lines: tuple[bytes, ...], enctype: bytes) -> bytes:
    if enctype == b"base64":
        joined = b"".join(line.strip() for line in lines)
        decoded = base64.b64decode(joined, validate=True)
        if not decoded or base64.b64encode(decoded) != joined:
            raise ValueError("expected canonical Base64")
        return decoded
    if enctype != b"uuencode":
        raise ValueError("unsupported fixture encoding")

    payload = lines
    if payload and payload[0].startswith(b"begin "):
        if len(payload) < 4 or payload[-1] != b"end" or payload[-2] not in (b" ", b"`"):
            raise ValueError("incomplete uuencode framing")
        payload = payload[1:-2]
    decoded_lines = []
    for line in payload:
        decoded = binascii.a2b_uu(line)
        canonical = binascii.b2a_uu(decoded, backtick=True).rstrip(b"\n")
        if not decoded or canonical != line.replace(b" ", b"`"):
            raise ValueError("invalid uuencode data line")
        decoded_lines.append(decoded)
    if not decoded_lines:
        raise ValueError("empty uuencode block")
    return b"".join(decoded_lines)


def parse_blocks(envelope: bytes) -> dict[bytes, Block]:
    lines = [line for line in envelope.splitlines() if line]
    encoding = {}
    blocks = {}
    for index, line in enumerate(lines):
        match = DIRECTIVE.fullmatch(line.strip())
        if match is None:
            continue
        directive = match[1]
        if directive.startswith(b"encoding"):
            encoding = attributes(directive)
        if directive not in BLOCKS:
            continue
        if directive in blocks:
            raise ValueError("duplicate key or data block")
        payload = []
        for candidate in lines[index + 1:]:
            if DIRECTIVE.fullmatch(candidate.strip()):
                break
            payload.append(candidate)
        enctype = encoding.get(b"enctype", b"base64")
        data_lines = tuple(line.strip() for line in payload if line.strip()) if enctype == b"base64" else tuple(payload)
        decoded = decode_payload(data_lines, enctype)
        preceding = next((line.strip() for line in reversed(lines[:index]) if line.strip()), b"")
        blocks[directive] = Block(data_lines, decoded, encoding, preceding)
    return blocks


def keeps_body(expected: bytes, recovered: bytes) -> bool:
    # Delimiter line breaks are structural. Optional added padding consists of comments.
    expected = expected.strip(b"\r\n")
    position = recovered.find(expected)
    return (position >= 0 and PADDING.fullmatch(recovered[:position]) is not None
            and PADDING.fullmatch(recovered[position + len(expected):]) is not None)


def invoke(command: list[str], data: bytes | None = None) -> bytes:
    run = subprocess.run(command, input=data, capture_output=True, timeout=60, check=False)
    if run.returncode:
        raise ValueError(f"command exited {run.returncode}")
    return run.stdout


def unwrap_session_key(openssl: str, private_key: Path, block: Block) -> bytes:
    return invoke([openssl, "pkeyutl", "-decrypt", "-inkey", str(private_key),
                   "-pkeyopt", "rsa_padding_mode:oaep", "-pkeyopt", "rsa_oaep_md:sha256",
                   "-pkeyopt", "rsa_mgf1_md:sha256"], block.decoded)


def decrypt_body(openssl: str, cipher: bytes, key: bytes, payload: bytes) -> bytes:
    if cipher not in CIPHERS:
        raise ValueError("unsupported fixture cipher")
    option, key_size = CIPHERS[cipher]
    if len(key) != key_size or len(payload) < 32 or len(payload) % 16:
        raise ValueError("invalid AES-CBC key or payload length")
    return invoke([openssl, "enc", "-d", "-" + option,
                   "-K", key.hex(), "-iv", payload[:16].hex()], payload[16:])


def recover(openssl: str, private_key: Path, blocks: dict[bytes, Block]) -> bytes:
    key = unwrap_session_key(openssl, private_key, blocks[b"key_block"])
    return decrypt_body(openssl, b"aes256-cbc", key, blocks[b"data_block"].decoded)


def has_descriptor(block: Block, enctype: bytes = b"base64") -> bool:
    return (block.encoding.get(b"enctype") == enctype
            and block.encoding.get(b"bytes") == str(len(block.decoded)).encode())


def detail(original: bytes, output: bytes, line_limit: int, byte_hint: int, decode) -> dict[str, bool]:
    result = dict.fromkeys(ENVELOPE_CHECKS, False)
    try:
        blocks = parse_blocks(output)
        data = blocks[b"data_block"]
        key = blocks[b"key_block"]
    except (ValueError, KeyError, binascii.Error):
        return result

    metadata = fields(original)
    exported = fields(output)
    expected_comment = next(line.strip() for line in original.splitlines()
                            if fields(line).get(b"comment") == metadata[b"comment"])
    result["clear_comment"] = data.preceding == expected_comment
    result["explicit_descriptors"] = has_descriptor(data) and has_descriptor(key)
    result["ignored_input_byte_hint"] = has_descriptor(data) and byte_hint != len(data.decoded)
    result["line_limit"] = max(map(len, data.lines)) <= line_limit
    try:
        recovered = decode(blocks)
    except (ValueError, subprocess.TimeoutExpired):
        return result

    module = MODULE.search(original)
    assert module is not None, "fixture must include its protected module"
    module_bytes_match = module.group(0) in recovered
    result["body_preserved"] = keeps_body(without_directives(original, EXPORTED), recovered)
    result["session_key"] = module_bytes_match
    result["cbc_iv_prefix"] = module_bytes_match
    result["aes256_identifier"] = exported.get(b"data_method") == b"aes256-cbc" and module_bytes_match
    result["base64_representation"] = (
        result["explicit_descriptors"] and module_bytes_match
        and all(len(line) <= 76 for name in BLOCKS for line in blocks[name].lines)
    )
    for name, check in ((b"author", "author_export"), (b"author_info", "author_info_export")):
        result[check] = (exported.get(name) == metadata[name] and name not in fields(recovered)
                         and metadata[name] not in recovered)
    result["comment_excluded"] = b"comment" not in fields(recovered) and metadata[b"comment"] not in recovered
    agent = exported.get(b"encrypt_agent")
    result["agent_output"] = agent == b"Python IEEE 1735 Encryptor" and agent not in recovered
    return result


def inspect(source: bytes, encrypted: bytes, decode) -> dict:
    original = split(source, SOURCE_BEGIN, SOURCE_END)
    checks = dict.fromkeys(LAYOUT_CHECKS + ENVELOPE_CHECKS, False)
    try:
        output = split(encrypted, OUTPUT_BEGIN, OUTPUT_END, FALLBACK_BEGIN)
    except ValueError:
        return checks
    aligned = len(output.bodies) == len(original.bodies) == 2
    if not aligned:
        return checks
    clear = all(
        without_directives(before, CONTROLS) == without_directives(after, CONTROLS)
        for before, after in zip(original.clear, output.clear)
    )
    scoped = all(output.opened)
    checks["clear_preserved"] = clear
    envelopes = []
    for index, (before, after) in enumerate(zip(original.bodies, output.bodies)):
        descriptor = fields(b"".join(original.clear[:index + 1]))
        envelopes.append(detail(before, after, int(descriptor[b"line_length"]), int(descriptor[b"bytes"]), decode))
    checks.update({name: all(body[name] for body in envelopes) for name in ENVELOPE_CHECKS})
    checks["end_output"] = clear and checks["session_key"]
    for name in ("author_export", "author_info_export"):
        checks[name] = checks[name] and scoped and clear
    for name in ("agent_output", "clear_comment", "explicit_descriptors"):
        checks[name] &= scoped
    checks["begin_output"] = (scoped and clear and checks["explicit_descriptors"]
                              and checks["agent_output"] and checks["aes256_identifier"])
    checks["begin_boundary"] = clear and checks["body_preserved"]
    checks["envelope_replacement"] = checks["begin_output"] and checks["begin_boundary"]
    return checks


def keyword_roles(source: bytes, encrypted: bytes, recipient: tuple[bytes, bytes], open_body) -> dict:
    original = split(source, SOURCE_BEGIN, SOURCE_END)
    checks = dict.fromkeys(ROLE_CHECKS, False)
    try:
        output = split(encrypted, OUTPUT_BEGIN, OUTPUT_END, FALLBACK_BEGIN)
    except ValueError:
        return checks
    if len(output.bodies) != 2 or len(original.bodies) != len(output.bodies):
        return checks

    clear_preserved = all(
        without_directives(before, CONTROLS) == without_directives(after, CONTROLS)
        for before, after in zip(original.clear, output.clear)
    )
    envelope_checks = []
    for index, (plain, protected) in enumerate(zip(original.bodies, output.bodies)):
        request = fields(b"".join(original.clear[:index + 1]))
        envelope_checks.append(keyword_envelope(plain, protected, request, recipient, open_body))
    for name in envelope_checks[0]:
        checks[name] = all(envelope[name] for envelope in envelope_checks)

    checks["encryption_boundaries"] = clear_preserved and checks["body_ciphertext"]
    checks["begin_decryption"] = checks["encryption_boundaries"] and all(output.opened)
    checks["end_decryption"] = checks["encryption_boundaries"]
    checks["self_contained"] = all(checks[name] for name in ROLE_CHECKS if name != "self_contained")
    return checks


def keyword_envelope(plain: bytes, protected: bytes, request: dict[bytes, bytes],
                     recipient: tuple[bytes, bytes], open_body) -> dict:
    checks = dict.fromkeys((
        "body_ciphertext", "key_ciphertext", "key_owner", "key_name", "key_method",
        "body_method", "encoding", "author", "author_info", "comment", "encrypt_agent",
    ), False)
    try:
        blocks = parse_blocks(protected)
        key_block, data_block = (blocks[name] for name in BLOCKS)
    except (ValueError, KeyError, binascii.Error):
        return checks

    supplied = fields(plain)
    output = fields(protected)
    owner, name = (output.get(b"key_keyowner"), output.get(b"key_keyname"))
    cipher = output.get(b"data_method")
    checks["key_owner"] = owner == recipient[0]
    checks["key_name"] = name == recipient[1]
    enctype = request[b"enctype"]
    checks["encoding"] = (all(has_descriptor(block, enctype) for block in (key_block, data_block))
                          and max(map(len, data_block.lines)) <= int(request[b"line_length"]))
    try:
        recovered, other_keys_rejected = open_body((owner, name), cipher, blocks)
    except (ValueError, KeyError, subprocess.TimeoutExpired):
        return checks

    checks["body_ciphertext"] = keeps_body(without_directives(plain, EXPORTED),
                                           without_directives(recovered, EXPORTED))
    checks["key_ciphertext"] = checks["body_ciphertext"] and other_keys_rejected
    checks["key_method"] = output.get(b"key_method") == b"rsa" and checks["key_ciphertext"]
    checks["body_method"] = cipher == request.get(b"data_method") and checks["body_ciphertext"]
    for field in EXPORTED:
        value = supplied[field]
        checks[field.decode("ascii")] = output.get(field) == value and value not in recovered
    agent = output.get(b"encrypt_agent")
    checks["encrypt_agent"] = agent == b"Python IEEE 1735 Encryptor" and agent not in recovered
    return checks


def exchange_key(openssl: str, directory: Path, name: str) -> tuple[Path, Path]:
    private = directory / f"{name}.pem"
    public = directory / f"{name}-public.pem"
    private.write_bytes(invoke([openssl, "genpkey", "-algorithm", "RSA", "-pkeyopt", "rsa_keygen_bits:2048"]))
    private.chmod(0o600)
    public.write_bytes(invoke([openssl, "pkey", "-in", str(private), "-pubout"]))
    return private, public


def encrypt(python: str, fixture: Path, public: Path, output: Path,
            recipient: tuple[bytes, bytes]) -> bytes:
    owner, name = (value.decode("ascii") for value in recipient)
    invoke([python, "-I", "-c", "from hdl_encrypt import main; main()",
            str(fixture), "-k", str(public), "-o", str(output), "--owner", owner, "--keyname", name])
    return output.read_bytes()


def open_for_recipient(openssl: str, keys: dict, recipient: tuple[bytes, bytes],
                       cipher: bytes, blocks: dict[bytes, Block]) -> tuple[bytes, bool]:
    key_block = blocks[b"key_block"]
    session_key = unwrap_session_key(openssl, keys[recipient][0], key_block)
    plain = decrypt_body(openssl, cipher, session_key, blocks[b"data_block"].decoded)
    other_keys_rejected = True
    for identity, (private, _) in keys.items():
        if identity == recipient:
            continue
        try:
            unwrap_session_key(openssl, private, key_block)
        except ValueError:
            continue
        other_keys_rejected = False
    return plain, other_keys_rejected


def compare_recipients(python: str, openssl: str, fixture: Path, directory: Path) -> dict:
    keys = {recipient: exchange_key(openssl, directory, f"recipient-{index}")
            for index, recipient in enumerate(RECIPIENTS)}
    source = fixture.read_bytes()
    runs = []
    for recipient, (_, public) in keys.items():
        protected = encrypt(python, fixture, public, directory / "protected.sv", recipient)
        checks = keyword_roles(
            source, protected, recipient,
            lambda identity, cipher, blocks: open_for_recipient(openssl, keys, identity, cipher, blocks),
        )
        runs.append({"owner": recipient[0].decode("ascii"), "key_name": recipient[1].decode("ascii"),
                     "checks": checks})
    return {"checks": {name: all(run["checks"][name] for run in runs) for name in ROLE_CHECKS},
            "recipient_runs": runs}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_slang.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def tool_info(python: str) -> dict:
    script = (
        "import hashlib, importlib.metadata as m, json;"
        "d=m.distribution('hdl-encrypt');"
        "print(json.dumps({'version':d.version,'files':{str(f):"
        "hashlib.sha256(d.locate_file(f).read_bytes()).hexdigest() for f in d.files "
        "if str(f).startswith('hdl_encrypt/') and str(f).endswith('.py')},"
        "'cryptography':m.version('cryptography')}))"
    )
    return json.loads(invoke([python, "-I", "-c", script]))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl", help="OpenSSL CLI executable")
    parser.add_argument("--json", required=True, type=Path, help="write qualification results")
    args = parser.parse_args()
    # Keep the venv interpreter pathname so Python can find the installed package.
    python = shutil.which(args.python)
    openssl = shutil.which(args.openssl)
    if python is None or openssl is None:
        parser.error("Python or OpenSSL is unavailable")
    info = tool_info(python)
    checker = checker_digest()
    inputs = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in sorted(CASES)}
    fingerprints = suite_results.fingerprints(list(inputs.values()))
    results = {}
    for case, fixture in inputs.items():
        if suite_results.header(fixture).get("expected_stdout") != CASES[case]:
            parser.error(f"unexpected control output for {case}")
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            if case == EXCHANGE_CASE:
                detail_result = compare_recipients(python, openssl, fixture, work)
            else:
                private, public = exchange_key(openssl, work, "fixture")
                protected = encrypt(python, fixture, public, work / "protected.sv",
                                    (b"Qualification", b"fixture-only"))
                checks = inspect(fixture.read_bytes(), protected, lambda blocks: recover(openssl, private, blocks))
                detail_result = {"checks": checks}
        results[case] = {"inputs_sha256": fingerprints[case], **detail_result}
    if (checker != checker_digest() or info != tool_info(python)
            or fingerprints != suite_results.fingerprints(list(inputs.values()))):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "encryptor": info, "openssl": invoke([openssl, "version"]).decode().strip(),
        "checker_sha256": checker, "tests": results,
    })
    for case, result in results.items():
        checks = result["checks"]
        print(f"{case}: {sum(checks.values())}/{len(checks)} checks match")
    return int(any(not all(result["checks"].values()) for result in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
