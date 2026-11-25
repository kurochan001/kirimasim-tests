#!/usr/bin/env python3
"""Qualify OpenPGP RSA and ElGamal fixtures and their envelope metadata."""

import argparse
from dataclasses import dataclass
import hashlib
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_icarus
import run_protect_author_digests as author
import run_protect_block_boundaries as boundaries
import run_protect_cipher_methods as cipher
import run_protect_digests as digests
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-openpgp-methods"
CHECKER = "tools/run_protect_openpgp_methods.py"
RSA = "ch34/test_protect_pgp_rsa_recovers_the_declared_payload"
ELG = "ch34/test_protect_elgamal_recovers_the_declared_payload"
CASES = {RSA: "protect pgp rsa=2d,5a", ELG: "protect elgamal=6c"}
METHODS = {b"pgp-rsa": (b"rsa2048", 1), b"elgamal": (b"elg2048", 16)}
AUTHOR_FIELDS = (b"author", b"author_info")
PACKET = re.compile(rb"^:pubkey enc packet: version (\d+), algo (\d+), keyid ([0-9a-fA-F]{16})\s*$", re.M)
ENCRYPTOR = b"Fixture OpenPGP packager"


@dataclass(frozen=True)
class Packet:
    version: int
    algorithm: int
    key_id: bytes


def checker_digest() -> str:
    digest = hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes())
    digest.update(author.checker_digest().encode())
    return digest.hexdigest()


def gpg_command(program: str, home: Path, *arguments: str) -> list[str]:
    return [program, "--no-options", "--homedir", str(home), "--batch", "--no-tty",
            "--pinentry-mode", "loopback", "--passphrase", "", "--no-auto-key-retrieve", *arguments]


def gpg_run(program: str, home: Path, *arguments: str, data: bytes | None = None) -> bytes:
    return protect.invoke(gpg_command(program, home, *arguments), data)


def fingerprints_by_algorithm(listing: bytes) -> dict[int, str]:
    lines = listing.splitlines()
    result = {}
    for line, following in zip(lines, lines[1:]):
        fields = line.split(b":")
        if fields[0] == b"sub" and following.startswith(b"fpr:"):
            result[int(fields[3])] = following.split(b":")[9].decode("ascii")
    return result


def fixture_keys(gpg: str, path: Path, label: str) -> dict[int, str]:
    path.mkdir(mode=0o700)
    gpg_run(gpg, path, "--quick-generate-key", f"{label} <{label}@example.invalid>", "rsa2048", "sign", "0")
    first = gpg_run(gpg, path, "--with-colons", "--list-keys")
    fingerprint = next(line.split(b":")[9].decode("ascii")
                       for line in first.splitlines() if line.startswith(b"fpr:"))
    for algorithm, _ in METHODS.values():
        gpg_run(gpg, path, "--quick-add-key", fingerprint, algorithm.decode(), "encr", "0")
    listing = gpg_run(gpg, path, "--with-colons", "--list-keys", fingerprint)
    keys = fingerprints_by_algorithm(listing)
    if set(keys) != {1, 16}:
        raise ValueError("expected one RSA and one ElGamal encryption subkey")
    return keys


def packet_summary(listing: bytes) -> Packet:
    matches = PACKET.findall(listing)
    if len(matches) != 1:
        raise ValueError("expected one public-key encrypted session-key packet")
    version, algorithm, key_id = matches[0]
    return Packet(int(version), int(algorithm), key_id.upper())


def validate_packet(selection: bytes, packet: Packet, fingerprint: str) -> None:
    if selection not in METHODS:
        raise ValueError("unregistered fixture method identifier")
    _, expected_algorithm = METHODS[selection]
    if packet.version != 3 or packet.algorithm != expected_algorithm:
        raise ValueError("OpenPGP packet disagrees with the selected method")
    if packet.key_id != fingerprint[-16:].upper().encode():
        raise ValueError("OpenPGP packet addresses another recipient")


def build_envelope(method: bytes, mode: bytes, fields: dict[bytes, bytes], wrapped: bytes,
                   agent_info: bytes | None) -> bytes:
    export = (author.PRAGMA + b"begin_protected\n"
              + author.method_line(b"data_method", method)
              + author.method_line(b"encrypt_agent", ENCRYPTOR)
              + b"".join(author.method_line(name, fields[name]) for name in AUTHOR_FIELDS))
    if agent_info is not None:
        export += author.method_line(b"encrypt_agent_info", agent_info)
    return export + digests.encoded_block(b"data_block", wrapped, mode) + author.PRAGMA + b"end_protected"


def open_envelope(gpg: str, home: Path, wire: bytes, fingerprint: str) -> tuple[bytes, Packet]:
    block = author.payload(wire, b"data_block")
    method = protect.fields(wire)[b"data_method"]
    packet = packet_summary(gpg_run(gpg, home, "--list-only", "--list-packets", data=block.decoded))
    validate_packet(method, packet, fingerprint)
    return gpg_run(gpg, home, "--decrypt", data=block.decoded), packet


def wrong_recipient_denied(gpg: str, home: Path, ciphertext: bytes) -> bool:
    result = subprocess.run(gpg_command(gpg, home, "--status-fd", "2", "--decrypt"),
                            input=ciphertext, capture_output=True, timeout=60)
    return (result.returncode > 0 and not result.stdout
            and b"[GNUPG:] NO_SECKEY" in result.stderr)


def elgamal_known_answer() -> bool:
    # A small, fixed arithmetic vector complements the real OpenPGP packet test.
    prime, generator, private, ephemeral, message = 467, 2, 127, 63, 123
    public = pow(generator, private, prime)
    left = pow(generator, ephemeral, prime)
    right = message * pow(public, ephemeral, prime) % prime
    opened = right * pow(pow(left, private, prime), -1, prime) % prime
    return (public, left, right, opened) == (132, 418, 326, 123)


def reference_method(gpg: str, receiver: Path, unrelated: Path, keys: dict[int, str],
                     agent_info: bytes, fixture: Path, work: Path, icarus_bin: Path) -> dict:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    original, = layout.bodies
    settings = protect.fields(layout.clear[0])
    inside_fields = protect.fields(original)
    method, mode = settings[b"data_method"], settings[b"enctype"]
    _, algorithm = METHODS[method]
    fingerprint = keys[algorithm]
    body = protect.without_directives(original, AUTHOR_FIELDS).strip(b"\r\n")
    wrapped = gpg_run(gpg, receiver, "--rfc2440", "--trust-model", "always", "--recipient",
                      fingerprint + "!", "--output", "-", "--encrypt", data=body)
    wire = build_envelope(method, mode, inside_fields, wrapped, agent_info)
    alternate = next(identifier for identifier in METHODS if identifier != method)
    wrong_label = wire.replace(author.method_line(b"data_method", method),
                               author.method_line(b"data_method", alternate), 1)
    recovered, packet = open_envelope(gpg, receiver, wire, fingerprint)
    external = layout.clear[0] + wire + layout.clear[1]
    output = protect.split(external, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
    body_wire, = output.bodies
    body_headers = protect.fields(body_wire)
    omitted = build_envelope(method, mode, inside_fields, wrapped, None)
    restored = work / fixture.name
    restored.write_bytes(output.clear[0] + b"\n" + recovered + b"\n" + output.clear[1])
    checks = {
        "selected_public_key_algorithm": packet.algorithm == algorithm and packet.version == 3,
        "opened_body_matches_bytes": recovered == body,
        "wrong_packet_label_rejected": author.rejected(lambda: open_envelope(gpg, receiver, wrong_label, fingerprint)),
        "wrong_private_key_rejected": wrong_recipient_denied(gpg, unrelated, wrapped),
        "public_key_packet_targets_selected_recipient": packet.key_id == fingerprint[-16:].upper().encode(),
        "active_payload_encoding": author.payload(body_wire, b"data_block").encoding[b"enctype"] == mode,
        "inside_author_fields_exported_separately": all(body_headers.get(field) == inside_fields[field]
                                                        for field in AUTHOR_FIELDS),
        "outside_author_fields_copied_unchanged": output.clear == layout.clear and all(
            settings[field] != body_headers[field] for field in AUTHOR_FIELDS
        ),
        "ordinary_author_like_comment_remains_in_body": any(
            b"// author" in line and b"ordinary HDL comment" in line for line in recovered.splitlines()),
        "metadata_absent_from_encrypted_body": all(
            author.PRAGMA + field not in recovered and inside_fields[field] not in recovered
            for field in AUTHOR_FIELDS
        ),
        "agent_info_in_envelope_outside_ciphertext": (
            body_headers.get(b"encrypt_agent") == ENCRYPTOR and body_headers.get(b"encrypt_agent_info") == agent_info
            and b"encrypt_agent_info" not in protect.fields(recovered) and agent_info not in recovered
        ),
        "optional_agent_info_can_be_omitted": (
            b"encrypt_agent_info" not in protect.fields(omitted)
            and open_envelope(gpg, receiver, omitted, fingerprint)[0] == body
        ),
        "recovered_hdl_matches": run_icarus.run(restored, icarus_bin)[0],
    }
    if method == b"elgamal":
        checks["elgamal_known_answer"] = elgamal_known_answer()
    return {"checks": checks, "packet_version": packet.version, "public_key_algorithm": packet.algorithm,
            "encoding": mode.decode()}


def native_method(python: str, openssl: str, work: Path, keys: tuple[Path, Path], fixture: Path) -> dict:
    source = fixture.read_bytes()
    selected = protect.fields(source)[b"data_method"]
    method_line = author.method_line(b"data_method", selected)
    begin = author.PRAGMA + b"begin\n"
    if source.count(method_line) != 1 or source.count(begin) != 1:
        raise ValueError("ambiguous native fixture insertion")
    private, public = keys
    variant, target = work / "native.sv", work / "native.out.sv"
    variants = {"before_begin": source,
                "inside_begin": source.replace(method_line, b"", 1).replace(begin, begin + method_line, 1)}
    results = {}
    for placement, modified in variants.items():
        variant.write_bytes(modified)
        target.unlink(missing_ok=True)
        try:
            run = cipher.run_encryptor(python, variant, public, target)
            if run.returncode != 0 or not target.is_file():
                results[placement] = {"outcome": "rejected_or_no_output", "exit": run.returncode}
                continue
            layout, recovered = boundaries.recovered_ranges(openssl, private, target.read_bytes())
            envelope, = layout.bodies
            cleartext, = recovered
        except (ValueError, KeyError, subprocess.TimeoutExpired):
            results[placement] = {"outcome": "invalid_or_unreadable_output"}
            continue
        plain, = protect.split(modified, protect.SOURCE_BEGIN, protect.SOURCE_END).bodies
        emitted = protect.fields(envelope)
        results[placement] = {
            "outcome": "substituted_data_method" if emitted.get(b"data_method") != selected
                       else "data_method_announced_in_cli_recipient_envelope",
            "emitted_data_method": emitted.get(b"data_method", b"").decode("ascii"),
            "cli_recipient_recovers_body": protect.keeps_body(plain, cleartext),
            "requested_directive_in_recovered_body": method_line in cleartext,
            "author_metadata_in_recovered_body": all(field in protect.fields(cleartext)
                                                     for field in AUTHOR_FIELDS),
            "agent_info_emitted": b"encrypt_agent_info" in emitted,
        }
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, epilog=(
        "Exit status reflects the independent controls. The optional native method observations are recorded in JSON."
    ))
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--gpg", default="gpg")
    parser.add_argument("--gpgconf", default="gpgconf")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl, gpg, gpgconf = map(shutil.which, (args.python, args.openssl, args.gpg, args.gpgconf))
    if not all((python, openssl, gpg, gpgconf)) or not (args.iverilog_bin / "iverilog").is_file():
        parser.error("Python, OpenSSL, GnuPG or Icarus is unavailable")
    gpg_version = protect.invoke([gpg, "--version"]).splitlines()[:2]
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    tests = {}
    # Keep fixture homes short enough for agent sockets and separate from user keys.
    with tempfile.TemporaryDirectory(prefix="hdl-pgp-", dir="/tmp") as directory:
        work = Path(directory)
        receiver, unrelated = work / "recipient", work / "unrelated"
        try:
            known = fixture_keys(gpg, receiver, "hdl-recipient")
            fixture_keys(gpg, unrelated, "hdl-unrelated")
            cli_keys = protect.exchange_key(openssl, work, "cli")
            for case, fixture in fixtures.items():
                tests[case] = {
                    "inputs_sha256": inputs[case],
                    "reference": reference_method(gpg, receiver, unrelated, known, b" / ".join(gpg_version),
                                                  fixture, work, args.iverilog_bin),
                    "native": native_method(python, openssl, work, cli_keys, fixture),
                }
        finally:
            for home in (receiver, unrelated):
                if home.is_dir():
                    subprocess.run([gpgconf, "--homedir", str(home), "--kill", "all"],
                                   timeout=10, capture_output=True, check=False)
    if (checker != checker_digest() or inputs != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Tool, checker or input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "checker_sha256": checker, "encryptor": tool,
        "gpg": [line.decode() for line in gpg_version],
        "openssl": protect.invoke([openssl, "version"]).decode().strip(),
        "icarus": protect.invoke([str(args.iverilog_bin / "iverilog"), "-V"]).decode().splitlines()[0],
        "tests": tests,
    })
    matched = True
    for case, item in tests.items():
        controls = item["reference"]["checks"]
        print(f"{case}: {sum(controls.values())}/{len(controls)} reference controls match")
        for placement, result in item["native"].items():
            print(f"  {placement}: {result['outcome']}")
        matched &= all(controls.values())
    return int(not matched)


if __name__ == "__main__":
    raise SystemExit(main())
