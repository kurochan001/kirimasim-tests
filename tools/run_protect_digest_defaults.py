#!/usr/bin/env python3
"""Qualify explicit defaults for omitted protection keywords."""

import argparse
from dataclasses import replace
import hashlib
import json
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile

import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_digests as digest
import run_protect_encryption as protect
import run_protect_public_keys as public
import suite_results


PROFILE = "protect-digest-defaults"
CHECKER = "tools/run_protect_digest_defaults.py"
CASE = "ch34/test_protect_digest_defaults_follow_data"
CASES = {CASE: "digest defaults=18,26,37,4b"}
DEFAULT_CLAUSES = {
    "digest_keyowner": "34.5.16.2",
    "digest_key_method": "34.5.17.2",
    "digest_keyname": "34.5.18.2",
    "digest_public_key": "34.5.19.2",
    "digest_decrypt_key": "34.5.20.2",
}


def checker_digest() -> str:
    fingerprint = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    fingerprint.update(public.checker_digest().encode())
    return fingerprint.hexdigest()


def symmetric_defaults(openssl: str, work: Path, recipient: tuple[Path, Path],
                       headers: dict[bytes, bytes], body: bytes) -> tuple[dict[str, bool], bytes]:
    method, mode, hash_method = (headers[name] for name in (b"data_method", b"enctype", b"digest_method"))
    key_size = protect.CIPHERS[method][1]
    data_key, explicit_digest_key = secrets.token_bytes(key_size), secrets.token_bytes(key_size)
    digest_value = hashlib.new(hash_method.decode(), body).digest()
    base = (author.method_line(b"data_method", method) + author.method_line(b"digest_method", hash_method)
            + digest.encoded_block(author.DATA_KEY, data_key, mode)
            + digest.encoded_block(b"data_block", boundaries.seal(openssl, method, data_key, body), mode))
    signing_private, signing_public = protect.exchange_key(openssl, work, "signing")
    signature = work / "author.sig"
    checks = {}
    for field, selected_key, other_field in (
        ("digest_key_method", explicit_digest_key, digest.encoded_block(author.DIGEST_KEY, explicit_digest_key, mode)),
        ("digest_decrypt_key", data_key, author.method_line(b"digest_key_method", method)),
    ):
        supplied = base + other_field + digest.encoded_block(
            b"digest_block", boundaries.seal(openssl, method, selected_key, digest_value), mode)
        field_is_absent = all(expression.partition(b" ")[0] != field.encode()
                              for expression in protect.DIRECTIVE.findall(supplied))
        signature.write_bytes(protect.invoke(
            [openssl, "dgst", "-sha256", "-sign", str(signing_private)], supplied))
        wire = author.wrap_author(openssl, signing_public, signature, recipient[1], supplied, mode)
        meta, keys = author.read_key_block(openssl, recipient[0], wire)
        recovered = author.authenticate(openssl, keys, wire, protect.fields(meta)[b"digest_method"])
        other_key = data_key if selected_key == explicit_digest_key else explicit_digest_key
        try:
            _, wrong_key_matches = author.authenticate(
                openssl, replace(keys, digest_key=other_key), wire, hash_method)
        except ValueError:
            wrong_key_matches = False
        checks[field] = (field_is_absent and keys.digest_key_method == method and keys.digest_key == selected_key
                         and recovered == (body, True) and not wrong_key_matches)
    return checks, recovered[0]


def asymmetric_defaults(openssl: str, work: Path, headers: dict[bytes, bytes],
                        body: bytes) -> tuple[dict[str, bool], bytes]:
    owner, name, mode, hash_method = (headers[field] for field in
                                      (b"data_keyowner", b"data_keyname", b"enctype", b"digest_method"))
    private, pem = protect.exchange_key(openssl, work, "body-key")
    der = protect.invoke([openssl, "pkey", "-pubin", "-in", str(pem), "-outform", "DER"])
    current = public.Selection(owner, name, b"rsa", der)
    registry = {(owner, name): public.KeyPair(private, der)}
    body_request = public.selection_text(current, public.DATA_FIELDS, mode)
    data = public.read_selection(body_request, public.DATA_FIELDS)
    body_wire = public.seal(openssl, work, body_request, public.DATA_FIELDS, registry, body, mode)
    recovered = public.decipher(openssl, registry[(owner, name)], author.payload(body_wire, b"data_block").decoded)
    value = hashlib.new(hash_method.decode(), recovered).digest()
    checks = {}
    explicit_request = public.selection_text(current, public.DIGEST_FIELDS, mode)
    for field, declaration in (
        ("digest_keyowner", author.method_line(b"digest_keyowner", owner)),
        ("digest_keyname", author.method_line(b"digest_keyname", name)),
        ("digest_public_key", digest.encoded_block(b"digest_public_key", der, mode)),
    ):
        request = explicit_request.replace(declaration, b"", 1)
        field_is_absent = all(expression.partition(b" ")[0] != field.encode()
                              for expression in protect.DIRECTIVE.findall(request))
        wire = public.seal(openssl, work, request, public.DIGEST_FIELDS, registry, value, mode, fallback=data)
        selected = public.read_selection(wire, public.DIGEST_FIELDS)
        pair = public.decryption_key(selected, public.DIGEST_FIELDS, registry)
        checks[field] = field_is_absent and selected == data and public.decipher(
            openssl, pair, author.payload(wire, b"digest_block").decoded) == value
    return checks, recovered


def reference_checks(openssl: str, iverilog: Path, fixture: Path, work: Path) -> dict:
    layout = protect.split(fixture.read_bytes(), protect.SOURCE_BEGIN, protect.SOURCE_END)
    headers = [protect.fields(clear) for clear in layout.clear[:-1]]
    bodies = [body.strip(b"\r\n") for body in layout.bodies]
    recipient = author.rsa_recipient(openssl, work)
    observations, restored = [], []
    for index, (header, body) in enumerate(zip(headers, bodies, strict=True)):
        directory = work / f"model-{index}"
        directory.mkdir()
        if header[b"data_method"] == b"rsa":
            checks, recovered = asymmetric_defaults(openssl, directory, header, body)
        else:
            checks, recovered = symmetric_defaults(openssl, directory, recipient, header, body)
        observations.append({
            "data_method": header[b"data_method"].decode(),
            "data_keyowner": header.get(b"data_keyowner", b"").decode(),
            "data_keyname": header.get(b"data_keyname", b"").decode(),
            "checks": checks, "body_recovered": recovered == body,
        })
        restored.append(recovered)
    target = work / fixture.name
    target.write_bytes(b"".join(prefix + b"\n" + body + b"\n"
                               for prefix, body in zip(layout.clear[:-1], restored, strict=True)) + layout.clear[-1])
    counts = {field: sum(field in row["checks"] for row in observations) for field in DEFAULT_CLAUSES}
    hdl = run_icarus.run(target, iverilog)[0]
    asymmetric = [row for row in observations if row["data_method"] == "rsa"]
    settings_differ = ({row["data_method"] for row in observations} == {"aes128-cbc", "aes256-cbc", "rsa"}
                       and len({row["data_keyowner"] for row in asymmetric}) == 2
                       and len({row["data_keyname"] for row in asymmetric}) == 2)
    return {"contexts": observations, "counts_by_omitted_keyword": counts,
            "data_settings_change_between_contexts": settings_differ, "recovered_hdl_matches": hdl}


def native_observation(python: str, openssl: str, fixture: Path, work: Path) -> dict:
    private, public_key = protect.exchange_key(openssl, work, "cli")
    source, requests = protect.SOURCE_BEGIN.subn(lambda start: start.group() + b"\n" + digest.REQUEST,
                                                fixture.read_bytes())
    requested = work / "digest-request.sv"
    requested.write_bytes(source)
    try:
        wire = protect.encrypt(python, requested, public_key, work / "native.sv", (b"Qualification", b"fixture-only"))
        layout, bodies = boundaries.recovered_ranges(openssl, private, wire)
    except (KeyError, OSError, ValueError, subprocess.TimeoutExpired):
        return {"outcome": "missing_or_unreadable_output", "digest_requests": requests}
    return {
        "outcome": "recovered", "recovered_bodies": len(bodies), "digest_requests": requests,
        "output_digest_blocks": sum(protect.DIRECTIVE.findall(body).count(b"digest_block") for body in layout.bodies),
        "requests_in_recovered_bodies": sum(body.count(digest.REQUEST) for body in bodies),
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
    inputs = suite_results.input_digest(fixture)
    checker, encryptor = checker_digest(), protect.tool_info(python)
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        reference = reference_checks(openssl, args.iverilog_bin, fixture, work)
        native = native_observation(python, openssl, fixture, work)
    if checker != checker_digest() or inputs != suite_results.input_digest(fixture) or encryptor != protect.tool_info(python):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    passed = (reference["recovered_hdl_matches"] and reference["data_settings_change_between_contexts"]
              and set(reference["counts_by_omitted_keyword"].values()) == {2}
              and all(row["body_recovered"] and all(row["checks"].values()) for row in reference["contexts"]))
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
