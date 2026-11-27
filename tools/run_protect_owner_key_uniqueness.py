#!/usr/bin/env python3
"""Qualify the scope of protection key registration for data and digests."""

import argparse
from dataclasses import dataclass, replace
import hashlib
import json
from pathlib import Path
import secrets
import shutil
import tempfile

import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_digests as digests
import run_protect_encryption as protect
import run_protect_public_keys as public
import suite_results


PROFILE = "protect-owner-key-uniqueness"
CHECKER = "tools/run_protect_owner_key_uniqueness.py"
CASE = "ch34/test_protect_key_values_unique_within_owner"
CASES = {CASE: "owner keys=21,56,9a"}
ROLES = {"data": public.DATA_FIELDS, "digest": public.DIGEST_FIELDS}
CIPHER = b"aes128-cbc"


@dataclass(frozen=True)
class Registration:
    owner: bytes
    name: bytes
    session: bytes
    pair: public.KeyPair


class DuplicateOwnerValue(ValueError):
    def __init__(self, keyword: bytes, owner: bytes):
        super().__init__(f"{keyword.decode()} is already registered for {owner.decode()}")
        self.keyword, self.owner = keyword, owner


def checker_digest() -> str:
    fingerprint = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    fingerprint.update(public.checker_digest().encode())
    fingerprint.update(boundaries.checker_digest().encode())
    return fingerprint.hexdigest()


def registration_text(row: Registration, fields: public.Fields, session_keyword: bytes, mode: bytes) -> bytes:
    return (author.method_line(fields.owner, row.owner) + author.method_line(fields.name, row.name)
            + digests.encoded_block(session_keyword, row.session, mode)
            + digests.encoded_block(fields.public, row.pair.public_der, mode))


def owner_registry(rows: tuple[Registration, ...], role: str, modes: tuple[bytes, ...]) -> dict:
    fields = ROLES[role]
    session_keyword = f"{role}_decrypt_key".encode()
    values = set()
    registry = {}
    for row, mode in zip(rows, modes, strict=True):
        request = registration_text(row, fields, session_keyword, mode)
        header = protect.fields(request)
        owner, name = header[fields.owner], header[fields.name]
        session = author.payload(request, session_keyword).decoded
        public_der = author.payload(request, fields.public).decoded
        for keyword, value in ((fields.name, name), (session_keyword, session), (fields.public, public_der)):
            lookup = (owner, keyword, value)
            if lookup in values:
                raise DuplicateOwnerValue(keyword, owner)
            values.add(lookup)
        registry[owner, name] = Registration(owner, name, session, public.KeyPair(row.pair.private, public_der))
    return registry


def rejection(role: str, first: Registration, duplicate: Registration, keyword: bytes) -> bool:
    try:
        owner_registry((first, duplicate), role, (b"base64", b"uuencode"))
    except DuplicateOwnerValue as error:
        return (error.keyword, error.owner) == (keyword, first.owner)
    return False


def key_roundtrip(openssl: str, work: Path, fields: public.Fields, registry: dict,
                  request: public.Selection, plain: bytes) -> tuple[bytes, bytes]:
    registered = registry[request.owner, request.name]
    sessions = {(item.owner, item.session): item.session for item in registry.values()}
    cipher = boundaries.seal(openssl, CIPHER, registered.session, plain)
    session_plain = protect.decrypt_body(openssl, CIPHER, sessions[request.owner, registered.session], cipher)

    pairs = {identity: item.pair for identity, item in registry.items()}
    encrypted = public.encipher(openssl, work, public.encryption_key(request, fields, pairs), plain)
    public_only = replace(request, name=None, public_der=registered.pair.public_der)
    asymmetric_plain = public.decipher(openssl, public.decryption_key(public_only, fields, pairs), encrypted)
    return session_plain, asymmetric_plain


def role_checks(openssl: str, work: Path, role: str, layout: protect.Layout) -> tuple[dict, tuple[bytes, ...]]:
    fields = ROLES[role]
    requests = tuple(public.read_selection(clear, fields) for clear in layout.clear[:-1])
    requests = tuple(replace(request, method=b"rsa") for request in requests)
    bodies = tuple(body.strip(b"\r\n") for body in layout.bodies)
    payloads = bodies if role == "data" else tuple(hashlib.sha1(body).digest() for body in bodies)
    keys = []
    for index, request in enumerate(requests):
        private, pem = protect.exchange_key(openssl, work, f"{role}-{index}")
        der = protect.invoke([openssl, "pkey", "-pubin", "-in", str(pem), "-outform", "DER"])
        keys.append(Registration(request.owner, request.name, secrets.token_bytes(protect.CIPHERS[CIPHER][1]),
                                 public.KeyPair(private, der)))
    first, second, third = keys
    modes = (b"base64", b"uuencode", b"uuencode")
    registry = owner_registry((first, second, third), role, modes)
    spread_registry = owner_registry((first, second, replace(first, owner=third.owner)), role, modes)
    restored = tuple(key_roundtrip(openssl, work, fields, registry, request, payload)
                     for request, payload in zip(requests, payloads, strict=True))
    across = key_roundtrip(openssl, work, fields, spread_registry, requests[2], payloads[2])
    duplicates = {
        fields.name.decode(): rejection(role, first, replace(second, name=first.name), fields.name),
        f"{role}_decrypt_key": rejection(role, first, replace(second, session=first.session),
                                         f"{role}_decrypt_key".encode()),
        fields.public.decode(): rejection(role, first, replace(second, pair=first.pair), fields.public),
    }
    checks = {
        "independent_owner_and_name_choices": first.owner == second.owner != third.owner
                                              and first.name == third.name != second.name,
        "distinct_material_per_registration": len({row.session for row in keys}) == 3
                                              and len({row.pair.public_der for row in keys}) == 3,
        "same_name_and_material_across_owners": across == (payloads[2], payloads[2]),
        "session_key_roundtrips": tuple(pair[0] for pair in restored) == payloads,
        "public_key_roundtrips": tuple(pair[1] for pair in restored) == payloads,
    }
    return {"checks": checks, "duplicates_rejected": duplicates}, tuple(pair[1] for pair in restored)


def reference_checks(openssl: str, icarus: Path, fixture: Path, work: Path) -> dict:
    layout = protect.split(fixture.read_bytes(), protect.SOURCE_BEGIN, protect.SOURCE_END)
    data, restored = role_checks(openssl, work, "data", layout)
    digest, _ = role_checks(openssl, work, "digest", layout)
    target = work / fixture.name
    target.write_bytes(b"".join(prefix + b"\n" + body + b"\n"
                               for prefix, body in zip(layout.clear[:-1], restored, strict=True)) + layout.clear[-1])
    return {"data": data, "digest": digest, "recovered_hdl_matches": run_icarus.run(target, icarus)[0]}


def native_observation(python: str, openssl: str, fixture: Path, work: Path) -> dict:
    private, pem = protect.exchange_key(openssl, work, "native")
    recipient = (b"Qualification", b"fixture-only")
    wire = protect.encrypt(python, fixture, pem, work / "native.sv", recipient)
    layout, recovered = boundaries.recovered_ranges(openssl, private, wire)
    original = protect.split(fixture.read_bytes(), protect.SOURCE_BEGIN, protect.SOURCE_END)
    headers = tuple(protect.fields(body) for body in layout.bodies)
    return {
        "recovered_bodies": sum(protect.keeps_body(body, plain)
                                for body, plain in zip(original.bodies, recovered)),
        "native_recipients": [[header[field].decode() for field in (b"key_keyowner", b"key_keyname")]
                              for header in headers],
        "output_owned_data_blocks": sum(b"data_keyowner" in header for header in headers),
        "output_owned_digest_blocks": sum(b"digest_keyowner" in header for header in headers),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl = shutil.which(args.python), shutil.which(args.openssl)
    if python is None or openssl is None or not (args.iverilog_bin / "iverilog").is_file():
        parser.error("Python, OpenSSL or Icarus is unavailable")
    fixture = suite_results.ROOT / "tests" / (CASE + ".sv")
    inputs, checker = suite_results.input_digest(fixture), checker_digest()
    encryptor = protect.tool_info(python)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        reference = reference_checks(openssl, args.iverilog_bin, fixture, work)
        native = native_observation(python, openssl, fixture, work)
    if checker != checker_digest() or inputs != suite_results.input_digest(fixture) or encryptor != protect.tool_info(python):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    passed = reference["recovered_hdl_matches"] and all(
        all(reference[role][group].values()) for role in ROLES for group in ("checks", "duplicates_rejected"))
    record = {"profile": PROFILE, "checker_sha256": checker, "encryptor": encryptor,
              "openssl": suite_results.tool_version([openssl, "version"]),
              "icarus": suite_results.tool_version([str(args.iverilog_bin / "iverilog"), "-V"]),
              "tests": {CASE: {"inputs_sha256": inputs, "reference": reference, "native": native, "pass": passed}}}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(f"{CASE}: reference {'pass' if passed else 'fail'}, native {native}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())
