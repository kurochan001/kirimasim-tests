#!/usr/bin/env python3
"""Measure reviewed IEEE 1800-2023 behavior obligations, separately from citations.

    python3 tools/behavior_coverage.py --update
    python3 tools/behavior_coverage.py --check
    python3 tools/behavior_coverage.py --results results/*.json --output /tmp/behavior.md
    python3 tools/behavior_coverage.py --require-complete

The whole-standard percentage is unknown until every normative section's own
text (including parent introductions and annexes) has been decomposed/reviewed.
Registered obligations and current execution evidence have separate denominators.
No requirement is inferred from :lrm:, a test name, :oracle: or a simulator pass.
"""

import argparse
import datetime
import hashlib
import json
import os
import re
import sys
from pathlib import Path

import suite_results
import doc_localization
import run_annex_n_reference
import run_coverage_bin_effects
import run_verilator_automatic_bin_limit
import run_unpacked_union_c_layout
import run_coverage_database_storage_profiles
import run_defparam_sources
import run_dpi_binary_compatibility
import run_dpi_chain_escape
import run_dpi_cxx_boundary
import run_dpi_foreign_preconditions
import run_dpi_legacy_source_layout
import run_dpi_native_struct_layout
import run_dpi_output_initial
import run_dpi_optional_packed_compatibility
import run_dpi_packed_storage
import run_dpi_prototype_guard
import run_dpi_pure_calls
import run_dpi_pure_io
import run_dpi_vpi_boundaries
import run_checker_free_choices
import run_config_precompiled_cells
import run_domain_boundaries
import run_fsm_transition_coverage
import run_ghost_checker_initialization
import run_ghost_coverage_database
import run_ghost_dpi_load
import run_ghost_class_stream_cycle
import run_ghost_config_expansion
import run_ghost_dpi_disabled_values
import run_ghost_dpi_function_ack
import run_ghost_dpi_versioned_dependencies
import run_ghost_evcd
import run_ghost_language_latitude
import run_ghost_sequence_method
import run_ghost_vpi_interactive_scope
import run_ghost_vpi_runtime_release
import run_ghost_vpi_restart_release
import run_ghost_vpi_start_callbacks
import run_ghost_vpi_valid_observation
import run_ghost_library_cells
import run_ghost_pulse_options
import run_ghost_timing_options
import run_icarus_control
import run_icarus_identifier_length
import run_icarus_iterator_release
import run_icarus_library_phases
import run_icarus_live_handle_release
import run_icarus_queue_allocation
import run_icarus_vendor_startup
import run_language_defaults
import run_language_diagnostics
import run_mailbox_bound_domain
import run_normative_reference_editions
import run_null_instance_access
import run_optional_lexical
import run_pli_region_controls
import run_preprocessor_effects
import run_process_control_target_origins
import run_protect_algorithm_extensions
import run_protect_author_digests
import run_protect_block_boundaries
import run_protect_cipher_methods
import run_protect_digest_defaults
import run_protect_digests
import run_protect_encodings
import run_protect_encryption
import run_protect_envelope_isolation
import run_protect_licenses
import run_protect_multiple_recipients
import run_protect_nested_decryption
import run_protect_openpgp_methods
import run_protect_owner_key_uniqueness
import run_protect_pragma_syntax
import run_protect_public_keys
import run_protect_viewport
import run_annex_declaration_checks
import run_slang_annex_library_map
import run_slang_source_checks
import run_soft_distribution
import run_scheduler_reference
import run_stacktrace
import run_verilator_dpi_context
import run_verilator_directive_extension
import run_verilator_class_collection
import run_weak_reference_collection
import run_verilator_constraint_calls
import run_verilator_libmap
import run_verilator_managed_storage
import run_verilator_vpi_dpi_bridge
import run_verilator_width_diagnostics
import run_vpi_compatibility_headers
import run_vpi_compatibility_scope
import run_vpi_host_default_modes
import run_vpi_frame_scope_editions
import run_vpi_legacy_applicability
import run_vpi_misc_format_extensions
import run_vpi_automatic_frame_lifetime
import run_vpi_class_reclaim
import run_vpi_diagram_key
import run_vpi_extended_attributes
import run_vpi_interface_ownership
import run_vpi_pattern_constraint_properties
import run_vpi_task_reference_parent
import run_vpi_protected_access
import run_vpi_protected_callbacks
import run_vpi_reserved_constant_ranges
import run_vpi_base_object_codes
import run_vpi_input_port_delays
import run_vpi_vlog_option_files
import run_waveform_sections

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "coverage"
REPORT = ROOT / "docs" / "behavior-coverage.md"
SUMMARY_REPORT = ROOT / "docs" / "behavior-coverage-summary.md"
SUMMARY_JSON = DATA / "behavior-summary.json"
METRIC_POLICY_VERSION = 3
OUTCOME_PRIORITY = ("pass", "fail", "known", "unsupported", "unreviewed_oracle", "stale", "not_run")
REVIEWS = {"unreviewed", "in_progress", "complete", "no_behavior"}
KINDS = {"normal", "boundary", "error"}
SIMULATORS = {"icarus", "verilator", "kirimasim", "lyra", "ghost", "sby"}
# The tools whose saved results anyone can reproduce: Icarus Verilog,
# Verilator and SymbiYosys. Ghost is a private build, and kirimasim and Lyra
# are the simulators being compared, so the second execution figure leaves
# them out; the first one is the union over every environment.
REPRODUCIBLE_SIMULATORS = ("icarus", "verilator", "sby")
FORMAL_TOOLS = ("sby",)
EVIDENCE_PROFILES = {
    run_coverage_bin_effects.PROFILE: ("verilator", run_coverage_bin_effects, run_coverage_bin_effects.CASES),
    run_verilator_automatic_bin_limit.PROFILE: (
        "verilator", run_verilator_automatic_bin_limit, run_verilator_automatic_bin_limit.CASES),
    run_unpacked_union_c_layout.PROFILE: (
        "verilator", run_unpacked_union_c_layout, run_unpacked_union_c_layout.CASES),
    **{profile: ("ghost", run_annex_n_reference, run_annex_n_reference.CASES)
       for profile in run_annex_n_reference.PROFILES.values()},
    **{profile: ("ghost", run_ghost_coverage_database, run_ghost_coverage_database.CASES)
       for profile, _, _ in run_ghost_coverage_database.SCENARIOS.values()},
    **{profile: (tool, run_language_diagnostics, run_language_diagnostics.CASES)
       for tool, profile in run_language_diagnostics.PROFILES.items()},
    **{profile: (tool, run_optional_lexical, dict.fromkeys(run_optional_lexical.CASES[tool]))
       for tool, profile in run_optional_lexical.PROFILES.items()},
    **{profile: (tool, run_language_defaults, run_language_defaults.CASES[tool])
       for tool, profile in run_language_defaults.PROFILES.items()},
    **{profile: (tool, run_waveform_sections, run_waveform_sections.CASES[tool])
       for tool, profile in run_waveform_sections.PROFILES.items()},
    run_dpi_binary_compatibility.PROFILE: ("ghost", run_dpi_binary_compatibility, run_dpi_binary_compatibility.CASES),
    **{profile: ("ghost", run_dpi_optional_packed_compatibility, run_dpi_optional_packed_compatibility.CASES)
       for profile in run_dpi_optional_packed_compatibility.PROFILES.values()},
    run_dpi_cxx_boundary.PROFILE: ("verilator", run_dpi_cxx_boundary, run_dpi_cxx_boundary.CASES),
    run_dpi_chain_escape.PROFILE: ("ghost", run_dpi_chain_escape, run_dpi_chain_escape.CASES),
    run_dpi_foreign_preconditions.PROFILE: (
        "verilator", run_dpi_foreign_preconditions, run_dpi_foreign_preconditions.CASES),
    run_dpi_native_struct_layout.PROFILE: ("ghost", run_dpi_native_struct_layout, run_dpi_native_struct_layout.CASES),
    run_dpi_packed_storage.PROFILE: ("ghost", run_dpi_packed_storage, run_dpi_packed_storage.CASES),
    **{profile: (tool, run_dpi_vpi_boundaries, dict.fromkeys([run_dpi_vpi_boundaries.CASE_BY_TOOL[tool]]))
       for tool, profile in run_dpi_vpi_boundaries.PROFILES.items()},
    run_verilator_vpi_dpi_bridge.PROFILE: (
        "verilator", run_verilator_vpi_dpi_bridge, run_verilator_vpi_dpi_bridge.CASES),
    run_defparam_sources.PROFILE: ("icarus", run_defparam_sources, run_defparam_sources.CASES),
    run_dpi_output_initial.PROFILE: ("verilator", run_dpi_output_initial, run_dpi_output_initial.CASES),
    run_dpi_prototype_guard.PROFILE: ("verilator", run_dpi_prototype_guard, run_dpi_prototype_guard.CASES),
    **{profile: (tool, run_dpi_pure_calls, run_dpi_pure_calls.CASES)
       for tool, profile in run_dpi_pure_calls.PROFILES.items()},
    **{profile: (tool, run_dpi_pure_io, run_dpi_pure_io.CASES)
       for tool, profile in run_dpi_pure_io.PROFILES.items()},
    run_domain_boundaries.PROFILE: ("icarus", run_domain_boundaries, run_domain_boundaries.CASES),
    run_fsm_transition_coverage.PROFILE: (
        "ghost", run_fsm_transition_coverage, run_fsm_transition_coverage.CASES),
    run_ghost_dpi_load.PROFILE: ("ghost", run_ghost_dpi_load, run_ghost_dpi_load.CASES),
    run_ghost_dpi_function_ack.PROFILE: ("ghost", run_ghost_dpi_function_ack, run_ghost_dpi_function_ack.CASES),
    run_ghost_dpi_disabled_values.PROFILE: (
        "ghost", run_ghost_dpi_disabled_values, run_ghost_dpi_disabled_values.CASES),
    run_ghost_dpi_versioned_dependencies.PROFILE: (
        "ghost", run_ghost_dpi_versioned_dependencies, run_ghost_dpi_versioned_dependencies.CASES),
    run_ghost_evcd.PROFILE: ("ghost", run_ghost_evcd, run_ghost_evcd.CASE_METHODS),
    run_ghost_class_stream_cycle.PROFILE: (
        "ghost", run_ghost_class_stream_cycle, run_ghost_class_stream_cycle.CASES),
    run_ghost_config_expansion.PROFILE: (
        "ghost", run_ghost_config_expansion, run_ghost_config_expansion.CASES),
    run_ghost_language_latitude.PROFILE: (
        "ghost", run_ghost_language_latitude, run_ghost_language_latitude.CASES),
    run_ghost_sequence_method.PROFILE: ("ghost", run_ghost_sequence_method, run_ghost_sequence_method.CASES),
    run_ghost_vpi_interactive_scope.PROFILE: (
        "ghost", run_ghost_vpi_interactive_scope, run_ghost_vpi_interactive_scope.CASES),
    run_ghost_vpi_runtime_release.PROFILE: (
        "ghost", run_ghost_vpi_runtime_release, run_ghost_vpi_runtime_release.CASES),
    run_ghost_vpi_restart_release.PROFILE: (
        "ghost", run_ghost_vpi_restart_release, run_ghost_vpi_restart_release.CASES),
    run_ghost_vpi_valid_observation.PROFILE: (
        "ghost", run_ghost_vpi_valid_observation, run_ghost_vpi_valid_observation.CASES),
    run_vpi_frame_scope_editions.PROFILE: (
        "ghost", run_vpi_frame_scope_editions, run_vpi_frame_scope_editions.CASES),
    **{profile: ("ghost", run_ghost_vpi_start_callbacks, run_ghost_vpi_start_callbacks.CASES)
       for profile in run_ghost_vpi_start_callbacks.PROFILES.values()},
    run_null_instance_access.PROFILE: ("verilator", run_null_instance_access, run_null_instance_access.CASES),
    run_mailbox_bound_domain.PROFILE: ("ghost", run_mailbox_bound_domain, run_mailbox_bound_domain.CASES),
    run_stacktrace.PROFILE: ("ghost", run_stacktrace, run_stacktrace.CASES),
    run_ghost_library_cells.PROFILE: ("ghost", run_ghost_library_cells, run_ghost_library_cells.CASES),
    run_ghost_checker_initialization.PROFILE: (
        "ghost", run_ghost_checker_initialization, run_ghost_checker_initialization.CASES),
    run_icarus_control.PROFILE: ("icarus", run_icarus_control, run_icarus_control.CASE_METHODS),
    run_icarus_vendor_startup.PROFILE: ("icarus", run_icarus_vendor_startup, run_icarus_vendor_startup.CASES),
    run_icarus_library_phases.PROFILE: (
        "icarus", run_icarus_library_phases, run_icarus_library_phases.CASES),
    run_icarus_identifier_length.PROFILE: (
        "icarus", run_icarus_identifier_length, run_icarus_identifier_length.CASES),
    run_icarus_iterator_release.PROFILE: (
        "icarus", run_icarus_iterator_release, run_icarus_iterator_release.CASES),
    run_icarus_live_handle_release.PROFILE: (
        "icarus", run_icarus_live_handle_release, run_icarus_live_handle_release.CASES),
    run_scheduler_reference.PROFILE: ("icarus", run_scheduler_reference, run_scheduler_reference.CASES),
    run_icarus_queue_allocation.PROFILE: (
        "icarus", run_icarus_queue_allocation, run_icarus_queue_allocation.CASES),
    run_verilator_constraint_calls.PROFILE: (
        "verilator", run_verilator_constraint_calls, run_verilator_constraint_calls.CASES),
    run_verilator_class_collection.PROFILE: (
        "verilator", run_verilator_class_collection, run_verilator_class_collection.CASES),
    run_weak_reference_collection.PROFILE: (
        "verilator-weak-collection-reference", run_weak_reference_collection, run_weak_reference_collection.CASES),
    run_verilator_libmap.PROFILE: ("verilator", run_verilator_libmap, run_verilator_libmap.CASE_MAPS),
    run_verilator_managed_storage.PROFILE: (
        "verilator", run_verilator_managed_storage, run_verilator_managed_storage.CASES),
    run_verilator_directive_extension.PROFILE: (
        "verilator", run_verilator_directive_extension, run_verilator_directive_extension.CASES),
    run_verilator_width_diagnostics.PROFILE: (
        "verilator", run_verilator_width_diagnostics, run_verilator_width_diagnostics.CASES),
    run_preprocessor_effects.PROFILE: (
        "verilator", run_preprocessor_effects, run_preprocessor_effects.CASES),
    # Compile-only qualification. Slang is outside SIMULATORS, so this profile
    # supplies reviewed design evidence and cannot count as simulation evidence.
    run_protect_pragma_syntax.PROFILE: ("slang", run_protect_pragma_syntax,
                                      run_protect_pragma_syntax.CASE_KEYWORDS),
    run_slang_annex_library_map.PROFILE: ("slang", run_slang_annex_library_map,
                                        run_slang_annex_library_map.CASES),
    run_annex_declaration_checks.GHOST_PROFILE: (
        "ghost", run_annex_declaration_checks, run_annex_declaration_checks.GHOST_CASES),
    run_annex_declaration_checks.SLANG_PROFILE: (
        "slang", run_annex_declaration_checks, run_annex_declaration_checks.SLANG_CASES),
    run_soft_distribution.PROFILE: ("ghost", run_soft_distribution, run_soft_distribution.CASES),
    run_slang_source_checks.PROFILE: ("slang", run_slang_source_checks, run_slang_source_checks.CASES),
    run_ghost_pulse_options.PROFILE: (
        "pulse-option-reference", run_ghost_pulse_options, run_ghost_pulse_options.CASES),
    run_ghost_timing_options.PROFILE: (
        "timing-option-reference", run_ghost_timing_options, run_ghost_timing_options.CASES),
    run_pli_region_controls.PROFILE: (
        "pli-region-reference", run_pli_region_controls, run_pli_region_controls.CASES),
    run_checker_free_choices.PROFILE: (
        "checker-choice-reference", run_checker_free_choices, run_checker_free_choices.CASES),
    run_normative_reference_editions.PROFILE: (
        "normative-reference-editions", run_normative_reference_editions, run_normative_reference_editions.CASES),
    run_process_control_target_origins.PROFILE: (
        "ghost-process-origin-reference", run_process_control_target_origins, run_process_control_target_origins.CASES),
    run_config_precompiled_cells.PROFILE: (
        "config-precompiled-cells-reference", run_config_precompiled_cells, run_config_precompiled_cells.CASES),
    run_vpi_base_object_codes.PROFILE: (
        "vpi-base-object-code-reference", run_vpi_base_object_codes, run_vpi_base_object_codes.CASES),
    run_vpi_input_port_delays.PROFILE: (
        "input-port-delay-reference", run_vpi_input_port_delays, run_vpi_input_port_delays.CASES),
    run_vpi_misc_format_extensions.PROFILE: (
        "vpi-misc-formats-reference", run_vpi_misc_format_extensions, run_vpi_misc_format_extensions.CASES),
    run_vpi_automatic_frame_lifetime.PROFILE: (
        "verilator-frame-lifetime-reference", run_vpi_automatic_frame_lifetime, run_vpi_automatic_frame_lifetime.CASES),
    run_vpi_class_reclaim.PROFILE: (
        "verilator-class-reclaim-reference", run_vpi_class_reclaim, run_vpi_class_reclaim.CASES),
    run_vpi_diagram_key.PROFILE: (
        "ieee-vpi-diagram-key", run_vpi_diagram_key, run_vpi_diagram_key.CASES),
    run_vpi_extended_attributes.PROFILE: (
        "ghost-extended-attribute-reference", run_vpi_extended_attributes, run_vpi_extended_attributes.CASES),
    run_vpi_interface_ownership.PROFILE: (
        "ghost-interface-ownership-reference", run_vpi_interface_ownership, run_vpi_interface_ownership.CASES),
    run_vpi_pattern_constraint_properties.PROFILE: (
        "ghost-pattern-constraint-reference", run_vpi_pattern_constraint_properties,
        run_vpi_pattern_constraint_properties.CASES),
    run_vpi_task_reference_parent.PROFILE: (
        "ghost-task-reference-parent", run_vpi_task_reference_parent, run_vpi_task_reference_parent.CASES),
    run_vpi_protected_access.PROFILE: (
        "vpi-protected-access-reference", run_vpi_protected_access, run_vpi_protected_access.CASES),
    run_vpi_protected_callbacks.PROFILE: (
        "vpi-protected-callbacks-reference", run_vpi_protected_callbacks, run_vpi_protected_callbacks.CASES),
    run_dpi_legacy_source_layout.PROFILE: (
        "dpi-legacy-source-layout-reference", run_dpi_legacy_source_layout, run_dpi_legacy_source_layout.CASES),
    run_coverage_database_storage_profiles.PROFILE: (
        "coverage-database-storage-reference", run_coverage_database_storage_profiles,
        run_coverage_database_storage_profiles.CASES),
    # Standalone encryptor qualification also stays outside SIMULATORS.
    run_protect_encryption.PROFILE: ("hdl-encrypt", run_protect_encryption, run_protect_encryption.CASES),
    run_protect_algorithm_extensions.PROFILE: (
        "hdl-encrypt", run_protect_algorithm_extensions, run_protect_algorithm_extensions.CASES),
    run_protect_digest_defaults.PROFILE: (
        "hdl-encrypt", run_protect_digest_defaults, run_protect_digest_defaults.CASES),
    run_protect_envelope_isolation.PROFILE: (
        "hdl-encrypt", run_protect_envelope_isolation, run_protect_envelope_isolation.CASES),
    run_protect_author_digests.PROFILE: ("hdl-encrypt", run_protect_author_digests, run_protect_author_digests.CASES),
    run_protect_block_boundaries.PROFILE: ("hdl-encrypt", run_protect_block_boundaries, run_protect_block_boundaries.CASES),
    run_protect_cipher_methods.PROFILE: ("hdl-encrypt", run_protect_cipher_methods, run_protect_cipher_methods.CASES),
    run_protect_digests.PROFILE: ("hdl-encrypt", run_protect_digests, run_protect_digests.CASES),
    run_protect_encodings.PROFILE: ("hdl-encrypt", run_protect_encodings, run_protect_encodings.CASES),
    run_protect_licenses.PROFILE: ("hdl-encrypt", run_protect_licenses, run_protect_licenses.CASES),
    run_protect_multiple_recipients.PROFILE: (
        "hdl-encrypt", run_protect_multiple_recipients, run_protect_multiple_recipients.CASES),
    run_protect_owner_key_uniqueness.PROFILE: (
        "hdl-encrypt", run_protect_owner_key_uniqueness, run_protect_owner_key_uniqueness.CASES),
    run_protect_nested_decryption.PROFILE: (
        "hdl-encrypt", run_protect_nested_decryption, run_protect_nested_decryption.CASES),
    run_protect_openpgp_methods.PROFILE: (
        "hdl-encrypt", run_protect_openpgp_methods, run_protect_openpgp_methods.CASES),
    run_protect_public_keys.PROFILE: ("hdl-encrypt", run_protect_public_keys, run_protect_public_keys.CASES),
    run_protect_viewport.PROFILE: ("hdl-encrypt", run_protect_viewport, run_protect_viewport.CASES),
    run_verilator_dpi_context.PROFILE: ("verilator-codegen", run_verilator_dpi_context,
                                      run_verilator_dpi_context.CASES),
    run_vpi_compatibility_headers.PROFILE: ("vpi-header-compiler", run_vpi_compatibility_headers,
                                            run_vpi_compatibility_headers.CASES),
    run_vpi_compatibility_scope.PROFILE: ("ghost", run_vpi_compatibility_scope, run_vpi_compatibility_scope.CASES),
    run_vpi_host_default_modes.PROFILE: (
        "vpi-host-default-reference", run_vpi_host_default_modes, run_vpi_host_default_modes.CASES),
    run_vpi_reserved_constant_ranges.PROFILE: (
        "verilator", run_vpi_reserved_constant_ranges, run_vpi_reserved_constant_ranges.CASES),
    **{profile: ("ghost", run_vpi_legacy_applicability, run_vpi_legacy_applicability.CASES)
       for profile in run_vpi_legacy_applicability.PROFILES.values()},
    run_vpi_vlog_option_files.PROFILE: (
        "ghost", run_vpi_vlog_option_files, run_vpi_vlog_option_files.CASES),
}
# Simulators no longer run whose snapshots stay in the behavior history.
RETIRED_SIMULATORS = ("nvc",)


class InvalidCoverage(ValueError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise InvalidCoverage(message)


def section_key(number: str) -> tuple:
    parts = number.split(".")
    first = int(parts[0]) if parts[0].isdigit() else 100 + ord(parts[0])
    return first, *(int(p) for p in parts[1:])


def local_file(name: str) -> Path:
    require(isinstance(name, str) and name, "empty file reference")
    path = (ROOT / name).resolve()
    require(not Path(name).is_absolute() and path.is_relative_to(ROOT),
            f"file outside repository: {name}")
    require(path.is_file(), f"missing file: {name}")
    return path


def simulation_output_witness(fields: dict[str, str]) -> bool:
    return (fields.get("type") == "simulation" and not fields.get("should_fail_because")
            and bool(fields.get("expected_stdout")))


def runtime_diagnostic_witness(fields: dict[str, str]) -> bool:
    """A simulation that checks both a diagnostic and its expected output."""
    return simulation_output_witness(fields) and bool(fields.get("expected_stderr_regex"))


def undefined_input_requirement(checker, rid: str) -> bool:
    """An explicit checker scope for a prohibited input with optional diagnosis."""
    return rid in getattr(checker, "UNDEFINED_INPUT_REQUIREMENTS", ())


def validate(inventory: dict, registry: dict) -> tuple[dict, list]:
    """Reject malformed/stale links; an intentionally unmapped obligation is valid."""
    require(inventory.get("schema") == registry.get("schema") == 1, "unknown schema")
    denominator = registry.get("denominator_review", {"state": "pending"})
    require(denominator.get("state") in ("pending", "approved"), "invalid denominator review")
    if denominator["state"] == "approved":
        require(all(denominator.get(k) for k in ("reviewer", "reviewed_on", "scope_note")),
                "approved denominator needs review metadata")
    sections = {}
    for s in inventory["sections"]:
        number = s["id"]
        require(re.fullmatch(r"(?:[1-9]|[1-3][0-9]|4[01]|[A-Q])(?:\.[1-9][0-9]*)*",
                             number), f"invalid section {number}")
        require(number not in sections, f"duplicate section {number}")
        require(s.get("title") and isinstance(s.get("pdf_page"), int)
                and 1 <= s["pdf_page"] <= inventory["source"]["pdf_pages"],
                f"invalid source location {number}")
        require(s.get("kind") in ("normative", "informative"), f"invalid kind {number}")
        require(s.get("review") in REVIEWS, f"invalid review {number}")
        if s["review"] in ("complete", "no_behavior"):
            require(s.get("review_note") and s.get("reviewed_on"),
                    f"completed audit needs a rationale/date: {number}")
        sections[number] = s
    roots = {str(n) for n in range(1, 42)} | set("ABCDEFGHIJKLMNOPQ")
    require(roots <= sections.keys(), "inventory must include clauses 1–41 and annexes A–Q")
    for number in sections:
        if "." in number:
            require(number.rsplit(".", 1)[0] in sections, f"missing parent of {number}")
    # The baseline locks the imported section set as well as registered IDs.
    rows, ids = [], set()
    digest_cache = {}
    for r in registry["requirements"]:
        rid = r["id"]
        require(re.fullmatch(r"SV2023-[A-Z0-9.-]+", rid), f"invalid behavior ID {rid}")
        require(rid not in ids, f"duplicate behavior ID {rid}")
        ids.add(rid)
        require(r.get("clause") in sections, f"unknown clause: {rid}")
        require(sections[r["clause"]]["kind"] == "normative", f"informative behavior: {rid}")
        require(sections[r["clause"]]["review"] != "no_behavior",
                f"no_behavior section has a requirement: {rid}")
        require(r.get("kind") in KINDS, f"invalid case kind: {rid}")
        require(all(isinstance(r.get(k), str) and r[k].strip()
                    for k in ("behavior", "acceptance", "source_note")),
                f"behavior, acceptance and source_note required: {rid}")
        groups = r.get("check_groups", [])
        require(isinstance(groups, list), f"invalid check groups: {rid}")
        checks, seen, error_witnesses = [], set(), set()
        for c in r["checks"]:
            test = local_file(c["test"])
            require(test in suite_test_paths(), f"not a suite test: {c['test']}")
            require(c["test"] not in seen, f"duplicate test mapping: {rid}")
            seen.add(c["test"])
            fields = suite_results.header(test)
            require(r["clause"] in fields.get("lrm", "").split()[1:],
                    f"test must cite mapped clause {r['clause']}: {c['test']}")
            profile = c.get("evidence_profile")
            checker = None
            rejected_design = bool(fields.get("should_fail_because"))
            if profile is not None:
                require(isinstance(profile, str) and profile in EVIDENCE_PROFILES,
                        f"unsupported evidence profile: {rid}")
                _, checker, cases = EVIDENCE_PROFILES[profile]
                require(suite_results.test_id(test) in cases
                        and (simulation_output_witness(fields)
                             or profile == run_verilator_libmap.PROFILE and rejected_design),
                        f"unsupported evidence profile: {rid}")
            runtime_error = r["kind"] == "error" and runtime_diagnostic_witness(fields)
            profile_anchor = None
            if r["kind"] == "error" and rid in getattr(checker, "DIAGNOSTIC_REQUIREMENTS", ()):
                profile_anchor = checker.DIAGNOSTIC_ANCHOR
            if r["kind"] == "error" and undefined_input_requirement(checker, rid):
                profile_anchor = checker.UNDEFINED_INPUT_ANCHOR
            companion = r["kind"] == "error" and groups and simulation_output_witness(fields)
            require(rejected_design == (r["kind"] == "error") or runtime_error or profile_anchor or companion,
                    f"negative/positive case mismatch: {rid}")
            if rejected_design or runtime_error or profile_anchor:
                error_witnesses.add(c["test"])
            require(re.fullmatch(r"\d{4}-\d{2}-\d{2}", c.get("reviewed_on", ""))
                    and c.get("reviewer") and c.get("observation"),
                    f"mapping needs review date, reviewer and observation: {rid}")
            if test not in digest_cache:
                digest_cache[test] = suite_results.input_digest(test)
            require(c.get("inputs_sha256") == digest_cache[test],
                    f"stale reviewed mapping: {rid} -> {c['test']}; review changed inputs")
            inputs = set(suite_results.input_files(test))
            anchors = c.get("evidence", [])
            if checker is not None:
                require(any(a["file"] == checker.CHECKER for a in anchors),
                        f"mapping must identify the evidence checker: {rid}")
                inputs.add(local_file(checker.CHECKER))
            require(anchors and any(a["file"] == c["test"] for a in anchors),
                    f"mapping must identify a stimulus in the test: {rid}")
            expected = fields.get("expected_stdout", "")
            expected_path = (test.parent / expected[1:]).resolve() if expected.startswith("@") else test
            diagnostic_only = (expected.startswith("@") and expected_path.is_file()
                               and expected_path.stat().st_size == 0)
            if rejected_design:
                checked_oracle = any("expected_stderr_regex" in a["contains"] for a in anchors)
            else:
                output_anchor = any(local_file(a["file"]) == expected_path for a in anchors)
                diagnostic_anchor = any(a["file"] == c["test"] and
                                        a["contains"] == ":expected_stderr_regex: "
                                        + fields.get("expected_stderr_regex", "")
                                        for a in anchors)
                if profile_anchor:
                    checked_oracle = output_anchor and not diagnostic_only and any(
                        a["file"] == checker.CHECKER and profile_anchor in a["contains"] for a in anchors
                    )
                elif runtime_error:
                    checked_oracle = not diagnostic_only and output_anchor and diagnostic_anchor
                else:
                    checked_oracle = diagnostic_anchor if diagnostic_only else output_anchor
            require(checked_oracle,
                    f"mapping must identify the checked output/diagnostic: {rid}")
            for a in anchors:
                path = local_file(a["file"])
                require(path in inputs, f"evidence not among test inputs: {a['file']}")
                require(a.get("contains") and a["contains"] in path.read_text(encoding="utf-8"),
                        f"missing observation anchor: {rid} in {a['file']}")
            checks.append(c)
        if groups:
            group_ids, members = set(), set()
            for group in groups:
                require(isinstance(group.get("id"), str)
                        and re.fullmatch(r"[A-Za-z0-9_.-]+", group["id"])
                        and group["id"] not in group_ids,
                        f"duplicate/empty check group: {rid}")
                group_ids.add(group["id"])
                require(group.get("reviewer") and group.get("observation")
                        and re.fullmatch(r"\d{4}-\d{2}-\d{2}", group.get("reviewed_on", "")),
                        f"check group needs collective review: {rid}")
                tests = group.get("tests", [])
                require(isinstance(tests, list) and tests and len(tests) == len(set(tests))
                        and set(tests) <= seen, f"unknown/duplicate check group member: {rid}")
                require(r["kind"] != "error" or bool(error_witnesses.intersection(tests)),
                        f"error check group needs a diagnostic or rejection witness: {rid}")
                members.update(tests)
            require(members == seen, f"check group leaves an ungrouped test: {rid}")
        rows.append({**r, "mapped": bool(checks)})
    for number, s in sections.items():
        if s["review"] == "complete":
            require(any(r["clause"] == number for r in rows),
                    f"complete section has no decomposed obligations: {number}")
    return sections, rows


_test_paths = None


def suite_test_paths() -> set:
    global _test_paths
    if _test_paths is None:
        _test_paths = set(suite_results.find_tests())
    return _test_paths


def baseline(sections: dict, rows: list, source: dict | None = None) -> dict:
    structure = [{k: s[k] for k in ("id", "title", "pdf_page", "kind")}
                 for _, s in sorted(sections.items(), key=lambda item: section_key(item[0]))]
    return {"schema": 1,
            "inventory_sha256": hashlib.sha256(json.dumps(
                [source, structure], sort_keys=True).encode()).hexdigest(),
            "sections": sorted(sections, key=section_key),
            "normative_sections": sorted((n for n, s in sections.items()
                                           if s["kind"] == "normative"), key=section_key),
            "requirements": sorted(r["id"] for r in rows),
            "contracts": {r["id"]: hashlib.sha256(json.dumps(
                {k: r[k] for k in ("clause", "kind", "behavior", "acceptance", "source_note")},
                sort_keys=True).encode()).hexdigest() for r in rows},
            "witness_groups": {r["id"]: hashlib.sha256(json.dumps(
                {"groups": r["check_groups"], "checks": r["checks"]},
                sort_keys=True).encode()).hexdigest() for r in rows if r.get("check_groups")},
            "mapped": sorted(r["id"] for r in rows if r["mapped"]),
            "audited_sections": sorted((n for n, s in sections.items()
                                        if s["review"] in ("complete", "no_behavior")),
                                       key=section_key)}


def check_baseline(before: dict, after: dict) -> None:
    require(before.get("schema") == 1, "unknown baseline schema")
    require(before["inventory_sha256"] == after["inventory_sha256"],
            "standard inventory/source changed; review and explain a baseline update")
    if "source_index_sha256" in before:
        require(before["source_index_sha256"] == after.get("source_index_sha256"),
                "source-block inventory changed; reconcile the PDF/text and explain a baseline update")
    if "source_reviewed_sections" in before:
        require(set(before["source_reviewed_sections"]) <= set(after.get("source_reviewed_sections", [])),
                "source review regression: previously classified sections are missing")
    for key in ("sections", "normative_sections", "requirements", "mapped", "audited_sections"):
        lost = set(before[key]) - set(after[key])
        require(not lost, f"coverage regression ({key}): {', '.join(sorted(lost))}")
    for rid, digest in before["contracts"].items():
        require(after["contracts"].get(rid) == digest,
                f"behavior contract changed: {rid}; review and explain a baseline update")
    for rid, digest in before.get("witness_groups", {}).items():
        require(after.get("witness_groups", {}).get(rid) == digest,
                f"collective witness changed: {rid}; review and explain a baseline update")


def execution(rows: list, result_paths: list[Path]) -> tuple[dict, list]:
    """Only fresh pass results count. Files are separate snapshots, never merged
    across versions/runs to make a single simulator appear to cover more cases.
    """
    snapshots, ignored = [], []
    digests = {}
    test_ids = {}
    checker_digests = {}
    for path in sorted(result_paths):
        data = json.loads(path.read_text(encoding="utf-8"))
        simulator = data.get("simulator")
        configuration = data.get("configuration") or {}
        profile = configuration.get("evidence_profile")
        checker = None
        if profile is not None:
            registered = EVIDENCE_PROFILES.get(profile) if isinstance(profile, str) else None
            if registered is None or simulator != registered[0]:
                ignored.append(f"{path.name}: unknown or stale evidence profile")
                continue
            _, checker, cases = registered
            if profile not in checker_digests:
                checker_digests[profile] = checker.checker_digest()
            if (configuration.get("checker_sha256") != checker_digests[profile]
                    or not set(data.get("tests", {})) <= cases.keys()):
                ignored.append(f"{path.name}: unknown or stale evidence profile")
                continue
        if (simulator not in SIMULATORS or not data.get("version")
                or not data.get("generated_at") or data.get("runner_changed")
                or data.get("runner_sha256") != suite_results.runner_digest(simulator)):
            ignored.append(f"{path.name}: legacy, unknown, or stale runner provenance")
            continue
        executed, stale, outcomes = set(), 0, {}
        for r in rows:
            if r.get("interpretation_issue"):
                outcomes[r["id"]] = "interpretation_pending"
                continue
            if not r["mapped"]:
                outcomes[r["id"]] = "unmapped"
                continue
            by_test = {}
            for c in r["checks"]:
                if c.get("evidence_profile") != profile:
                    by_test[c["test"]] = "not_run"
                    continue
                test = ROOT / c["test"]
                if c["test"] not in test_ids:
                    test_ids[c["test"]] = suite_results.test_id(test)
                result = data.get("tests", {}).get(test_ids[c["test"]], {})
                if not result:
                    by_test[c["test"]] = "not_run"
                    continue
                if c["test"] not in digests:
                    digests[c["test"]] = suite_results.input_digest(test)
                if (result.get("inputs_changed")
                        or result.get("inputs_sha256") != digests[c["test"]]):
                    stale += 1
                    by_test[c["test"]] = "stale"
                    continue
                if result.get("status") != "pass":
                    by_test[c["test"]] = (result["status"] if result.get("status") in
                                           ("fail", "known", "unsupported") else "not_run")
                    continue
                # Unsupported syntax can satisfy a rejection test's line
                # regexp. It needs a reviewed, pinned oracle. Runtime
                # evidence checks diagnostics or entry into an undefined
                # input through an explicitly scoped profile.
                # A test recorded with Verilator 5.054 (added while the pin
                # moves from 5.052) counts only with a 5.054 run, and one
                # recorded with 5.052 only with a 5.052 run.
                fields = suite_results.header(test) if r["kind"] == "error" else {}
                positive_witness = (runtime_diagnostic_witness(fields)
                                    or undefined_input_requirement(checker, r["id"])
                                    or (r.get("check_groups") and simulation_output_witness(fields)))
                if r["kind"] == "error" and not positive_witness:
                    oracle = {"icarus": (("iverilog@13.0", r"version 13\.0(?:\s|$)"),),
                              "verilator": (("verilator@5.052", r"Verilator 5\.052(?:\s|$)"),
                                            ("verilator@5.054", r"Verilator 5\.054(?:\s|$)"))}
                    tokens = fields.get("oracle", "").split()
                    if not any(token in tokens and re.search(version, data["version"])
                               for token, version in oracle.get(simulator, ())):
                        by_test[c["test"]] = "unreviewed_oracle"
                        continue
                by_test[c["test"]] = "pass"
            # Alternatives: a requirement is executed when ONE group passes
            # whole (OR of groups, AND of the members of a group, in this one
            # result file). Several check_groups are alternative collective
            # witnesses, and checks without groups are each a group of one
            # (coverage/README "check_groups", FAQ Q19). The outcome of a
            # requirement without a passing group is the first of
            # OUTCOME_PRIORITY among its groups.
            groups = ([g["tests"] for g in r["check_groups"]] if r.get("check_groups")
                      else [[c["test"]] for c in r["checks"]])
            observed = set()
            for group in groups:
                states = {by_test[name] for name in group}
                observed.add("pass" if states == {"pass"} else
                             next(s for s in OUTCOME_PRIORITY[1:] if s in states))
            outcomes[r["id"]] = next((s for s in OUTCOME_PRIORITY if s in observed), "not_run")
            if outcomes[r["id"]] == "pass":
                executed.add(r["id"])
        snapshots.append({"file": path.name, "simulator": simulator,
                          "version": data["version"], "generated_at": data["generated_at"],
                          "executed": sorted(executed), "stale_links": stale,
                          "outcomes": outcomes,
                          "status_counts": {s: sum(v == s for v in outcomes.values())
                                            for s in (*OUTCOME_PRIORITY, "unmapped", "interpretation_pending")}})
    return {"snapshots": snapshots,
            "executed": sorted({rid for s in snapshots for rid in s["executed"]}),
            "executed_reproducible": sorted({rid for s in snapshots
                                             if s["simulator"] in REPRODUCIBLE_SIMULATORS
                                             for rid in s["executed"]}),
            # A formal check compares models and runs no simulator, so the
            # reports give the part confirmed by a simulator separately.
            "executed_simulated": sorted({rid for s in snapshots
                                          if s["simulator"] not in FORMAL_TOOLS
                                          for rid in s["executed"]}),
            "executed_reproducible_simulated": sorted({rid for s in snapshots
                                                       if s["simulator"] in REPRODUCIBLE_SIMULATORS
                                                       and s["simulator"] not in FORMAL_TOOLS
                                                       for rid in s["executed"]})}, ignored


def summarize(sections: dict, rows: list, runs: dict, denominator_reviewed: bool = False) -> dict:
    normative = {n: s for n, s in sections.items() if s["kind"] == "normative"}
    audited = sum(s["review"] in ("complete", "no_behavior") for s in normative.values())
    mapped = sum(r["mapped"] for r in rows)
    total_known = denominator_reviewed and audited == len(normative) and bool(rows)
    return {"sections": len(sections), "normative_sections": len(normative),
            "audited_sections": audited, "registered": len(rows), "mapped": mapped,
            "denominator_reviewed": denominator_reviewed,
            "extraction_progress_percent": 100 * audited / len(normative) if normative else None,
            "unmapped": len(rows) - mapped, "executed": len(runs["executed"]),
            "executed_reproducible": len(runs.get("executed_reproducible", ())),
            "executed_simulated": len(runs.get("executed_simulated", ())),
            "executed_reproducible_simulated": len(runs.get("executed_reproducible_simulated", ())),
            "whole_standard_percent": 100 * mapped / len(rows) if total_known else None,
            "whole_standard_executed_percent": 100 * len(runs["executed"]) / len(rows)
            if total_known else None,
            "registered_percent": 100 * mapped / len(rows) if rows else None}


def measurement(sections: dict, rows: list, runs: dict, source_audit: dict,
                denominator_reviewed: bool, inventory_sha256: str) -> dict:
    """Publish a provisional full-inventory metric without certifying its units.

    Every registered row remains in the denominator, including interpretation
    holds and unmapped rows. Partial source extraction never becomes a full-scope
    provisional percentage. The denominator identity excludes test mappings and
    run outcomes so ordinary testing progress remains comparable over time.
    """
    stats = summarize(sections, rows, runs, denominator_reviewed)
    complete_source = source_audit["source_review_complete"]
    executed = set(runs["executed"])
    reproducible = set(runs.get("executed_reproducible", ()))
    partition = {"pass": 0, "mapped_without_pass": 0, "unmapped": 0, "interpretation_pending": 0}
    chapters = []
    for r in rows:
        partition[requirement_status(r, executed)] += 1
    for root in sorted((n for n in sections if "." not in n), key=section_key):
        group = [r for r in rows if r["clause"].split(".")[0] == root]
        total = len(group)
        mapped = sum(r["mapped"] for r in group)
        passed = sum(r["id"] in executed for r in group)
        reproduced = sum(r["id"] in reproducible for r in group)
        chapters.append({"clause": root, "title": sections[root]["title"],
                         "registered": total, "mapped": mapped, "executed": passed,
                         "executed_reproducible": reproduced,
                         "design_percent": 100 * mapped / total if total else None,
                         "execution_percent": 100 * passed / total if total else None,
                         "execution_reproducible_percent": 100 * reproduced / total if total else None,
                         "interpretation_pending": sum(bool(r.get("interpretation_issue")) for r in group)})
    identity = {"metric_policy_version": METRIC_POLICY_VERSION,
                "inventory_sha256": inventory_sha256,
                "contracts": baseline(sections, rows)["contracts"]}
    linked_tests = {check["test"] for row in rows for check in row["checks"]}
    suite_tests = {test.relative_to(ROOT).as_posix() for test in suite_results.find_tests()}
    return {"metric_policy_version": METRIC_POLICY_VERSION,
            "whole_standard_status": ("confirmed" if stats["whole_standard_percent"] is not None
                                      else "provisional" if complete_source else "source_incomplete"),
            "provisional_design_percent": stats["registered_percent"] if complete_source else None,
            "provisional_execution_percent": (100 * len(executed) / len(rows)
                                               if complete_source and rows else None),
            "reproducible_simulators": list(REPRODUCIBLE_SIMULATORS),
            "provisional_execution_reproducible_percent": (100 * len(reproducible) / len(rows)
                                                            if complete_source and rows else None),
            "denominator": {"count": len(rows), "unit": "registered_requirement_condition_or_observation",
                            "sha256": hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest(),
                            "reviewed": denominator_reviewed, "source_review_complete": complete_source,
                            "interpretation_pending": partition["interpretation_pending"]},
            "test_mapping": {"suite_test_files": len(suite_tests),
                             "linked_test_files": len(linked_tests & suite_tests),
                             "unlinked_test_files": len(suite_tests - linked_tests)},
            "collective_requirement_count": sum(bool(r.get("check_groups")) for r in rows),
            "requirement_status_counts": partition, "chapters": chapters}


def requirement_status(row: dict, executed: set) -> str:
    if row.get("interpretation_issue"):
        return "interpretation_pending"
    if not row["mapped"]:
        return "unmapped"
    return "pass" if row["id"] in executed else "mapped_without_pass"


def compact_report(snapshot: dict, source_url: str | None = None,
                   detailed_report: str = "behavior-coverage.md") -> str:
    """A small, generated entry point; the full report retains each obligation."""
    def percent(value):
        return "未確定" if value is None else f"{value:.2f}%"
    def ratio(count, total):
        return f"{count}/{total} ({100 * count / total:.2f}%)" if total else "対象項目なし"
    link = lambda p: f"{source_url.rstrip('/')}/{p}" if source_url else f"../{p}"
    total = snapshot["registered"]
    counts = snapshot["requirement_status_counts"]
    scope = snapshot["denominator"]
    test_mapping = snapshot["test_mapping"]
    confirmed = snapshot["whole_standard_status"] == "confirmed"
    # The whole-standard figure without Ghost exists only with the one with Ghost.
    whole_reproducible = (None if snapshot["whole_standard_executed_percent"] is None
                          else 100 * snapshot["executed_reproducible"] / total)
    lines = ["# IEEE 1800-2023 要求カバレッジ集計", "",
             f"[全項目の詳細]({detailed_report}) / "
             f"[管理手順]({link('coverage/README.md')}) / "
             f"[解釈・再検討記録]({link('docs/requirement-extraction-notes.md')})", "",
             f"割合の分母は要求台帳の行で、テスト本数ではありません。[設計・実行・PASSの違い]({link('docs/faq.md')}#q16-how-do-design-and-execution-coverage-differ)を具体例で確認できます。", "",
             "## 全規格の要求台帳に対する値" if confirmed else "## 全規格の要求台帳に対する暫定値", "",
             f"- 要求カバレッジ（テスト設計）: **{percent(snapshot['provisional_design_percent'])}** "
             f"({snapshot['mapped']}/{total})。",
             f"- Ghostを除く実行確認率: **{percent(snapshot['provisional_execution_reproducible_percent'])}** "
             f"({snapshot['executed_reproducible']}/{total})。"
             "第三者が再現できるIcarus Verilog・Verilator・SymbiYosysの成功の和集合。"
             f"うちシミュレータで確認した要求は{snapshot['executed_reproducible_simulated']}行、"
             f"formalだけで確認した要求は"
             f"{snapshot['executed_reproducible'] - snapshot['executed_reproducible_simulated']}行です。",
             f"- 実行確認率: **{percent(snapshot['provisional_execution_percent'])}** "
             f"({snapshot['executed']}/{total})。複数環境の成功の和集合。"
             f"うちシミュレータで確認した要求は{snapshot['executed_simulated']}行、"
             f"formalだけで確認した要求は{snapshot['executed'] - snapshot['executed_simulated']}行です。",
             "- 分母には解釈保留と未対応も含みます。未実装・未対応を除外していません。",
             "- 登録単位は要求の出現箇所・条件・観測ケースであり、分母のレビューで意味の重複を統合しています。"
             if confirmed else
             "- 登録単位は要求の出現箇所・条件・初期の観測ケースであり、意味の重複整理前の暫定値です。",
             "  全プログラム・全入力の組み合わせを試した割合や、単一シミュレータの規格適合率ではありません。", "",
             "## 既存テストの集計状況", "",
             f"- 全 {test_mapping['suite_test_files']} 本のうち、要求との対応を登録済みのテストは "
             f"{test_mapping['linked_test_files']} 本。未登録は {test_mapping['unlinked_test_files']} 本です。",
             "- 上記の網羅率は、刺激と期待結果を確認して要求との対応を登録した分だけを計上しています。",
             "  未登録の既存テストも検証に役立ちますが、その貢献はまだ割合に反映できていません。",
             "- 登録済み本数は少なくとも一つの要求との対応がある本数で、テスト全体のレビュー完了数ではありません。", "",
             f"- 複数テストで分担する要求は {snapshot['collective_requirement_count']} 行。"
             "各グループの全テストが同じ実行回で成功した場合だけ、要求全体の実行成功に数えます。", "",
             "## 確定値", "",
             f"- 要求カバレッジ（テスト設計）: {percent(snapshot['whole_standard_percent'])}。",
             "- 規格要求の実行確認率: " + ("未確定。" if whole_reproducible is None else
                                   f"Ghostを除いて {percent(whole_reproducible)}、"
                                   f"Ghostとkirimasimを含めて {percent(snapshot['whole_standard_executed_percent'])}。"),
             f"- 分母の承認: {'承認済み' if scope['reviewed'] else '未承認'}。"
             f"計測状態: `{snapshot['whole_standard_status']}`。",
             "- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定しました。"
             if confirmed else
             "- 資料確認、保留解釈の解決、要求単位の重複整理、分母のレビューを経て確定します。", "",
             "## 残件", "",
             f"- 現行入力に対応するパス結果の記録あり: {counts['pass']} 行。",
             f"- 対応済み・パス結果の記録なし: {counts['mapped_without_pass']} 行。",
             f"- テスト対応未確認（解釈保留以外）: {counts['unmapped']} 行。",
             f"- 解釈保留: {counts['interpretation_pending']} 行。",
             "", "未対応は、既存テストが存在しないという判定ではありません。", "",
             "## シミュレータ別の実行確認率", "",
             f"各行は独立した保存実行です。小範囲の実行で未実行が多い場合もあるため、[日時・版・対象範囲の読み方]({link('docs/faq.md')}#q14-why-do-main-results-or-simulator-totals-differ)と計測元を確認してください。", ""]
    for run in snapshot["execution"]["snapshots"]:
        detail = run["status_counts"]
        lines += [f"- `{run['simulator']}` / {doc_localization.code_span(run['version'])}: {ratio(len(run['executed']), total)}。",
                  f"  計測元: {doc_localization.code_span(run['generated_at'])} / `{run['file']}`。",
                  f"  失敗 {detail['fail']}、既知不一致 {detail['known']}、未対応 {detail['unsupported']}、"
                  f"未実行 {detail['not_run']}、古い証跡 {detail['stale']}、"
                  f"規格違反テストの判定根拠が未承認 {detail['unreviewed_oracle']} 行。"]
    if not snapshot["execution"]["snapshots"]:
        lines.append("採用可能な実行証跡なし。")
    lines += [f"- 不採用の結果ファイル: {len(snapshot['ignored_results'])} 件。", "",
              "## 章・附属書別（登録項目に対する割合）", ""]
    for chapter in snapshot["chapters"]:
        lines.append(f"- {chapter['clause']} {chapter['title']}: "
                     f"テスト対応 {ratio(chapter['mapped'], chapter['registered'])}、"
                     f"実行確認 {ratio(chapter['executed'], chapter['registered'])}、"
                     f"Ghostを除く実行確認 {ratio(chapter['executed_reproducible'], chapter['registered'])}、"
                     f"解釈保留 {chapter['interpretation_pending']} 行。")
    lines += ["", "## 分母と履歴", "",
              f"- 分母SHA-256: `{scope['sha256']}`。",
              f"- 計測規則の版: {snapshot['metric_policy_version']}。",
              "- 履歴には分母の識別子、暫定値と確定値、環境別の状態内訳を保存します。",
              "  分母が異なる回の割合を、そのまま改善・悪化として比較しません。",
              "- この集計は保存済み実行証跡から再生成されます。上記の計測元時刻が実行時刻です。"]
    return "\n".join(lines) + "\n"


def drop_unknown_snapshots(data: dict) -> None:
    """Drops from each run of a behavior history the execution snapshots of a
    simulator outside SIMULATORS and RETIRED_SIMULATORS, counting them in the
    run's dropped_snapshots."""
    for run in data["runs"]:
        snapshots = run.get("execution", {}).get("snapshots", [])
        kept = [s for s in snapshots
                if s.get("simulator") in SIMULATORS | set(RETIRED_SIMULATORS)]
        if len(kept) != len(snapshots):
            run["execution"]["snapshots"] = kept
            run["dropped_snapshots"] = run.get("dropped_snapshots", 0) + len(snapshots) - len(kept)


def executed_digest(executed: list) -> str:
    """The SHA-256 of a snapshot's executed list, over its compact JSON text."""
    text = json.dumps(executed, ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def expand_history_lists(data: dict) -> None:
    """Replaces each {"same_as_sha256": digest} in a behavior history by the
    executed list that an earlier snapshot holds in full, so every snapshot
    holds its own list again."""
    full = {}
    for run in data["runs"]:
        for snapshot in run.get("execution", {}).get("snapshots", []):
            executed = snapshot.get("executed")
            if isinstance(executed, dict):
                digest = executed.get("same_as_sha256")
                require(digest in full, f"behavior history refers to an unknown executed list {digest}")
                snapshot["executed"] = list(full[digest])
            elif isinstance(executed, list):
                full.setdefault(executed_digest(executed), executed)


def compact_history_lists(data: dict) -> None:
    """Keeps each executed list in full only in the first snapshot that holds
    it; a later snapshot with the same list holds {"same_as_sha256": digest}
    instead, where digest is executed_digest of the list. Nothing is lost:
    expand_history_lists restores every list."""
    seen = set()
    for run in data["runs"]:
        for snapshot in run.get("execution", {}).get("snapshots", []):
            executed = snapshot.get("executed")
            if isinstance(executed, list):
                digest = executed_digest(executed)
                if digest in seen:
                    snapshot["executed"] = {"same_as_sha256": digest}
                else:
                    seen.add(digest)


def history_sharded(path: Path) -> bool:
    """A history path without the .json suffix is a directory of daily files."""
    return path.suffix != ".json"


def read_history(path: Path) -> dict:
    """The runs of a behavior history, in order: one JSON file, or a directory
    of daily files YYYY-MM-DD.json read by date. Before a directory's first
    write, the single file of the same name with .json (the former layout)
    is read first."""
    files = []
    if history_sharded(path):
        legacy = path.with_suffix(".json")
        if legacy.is_file():
            files.append(legacy)
        if path.is_dir():
            for shard in sorted(path.glob("*.json")):
                require(re.fullmatch(r"\d{4}-\d{2}-\d{2}\.json", shard.name),
                        f"unexpected file in the behavior history: {shard.name}")
                files.append(shard)
    elif path.is_file():
        files.append(path)
    runs = []
    for file in files:
        data = json.loads(file.read_text(encoding="utf-8"))
        require(data.get("schema") == 1 and isinstance(data.get("runs"), list),
                "unknown behavior history format")
        runs += data["runs"]
    return {"schema": 1, "runs": runs}


def history_days(runs: list) -> list[str]:
    """The daily file of each run: the UTC date it was measured, never earlier
    than that of the run before it, so the files read by date keep the order
    of the runs (a reference to an executed list always points back)."""
    days, last = [], "0000-00-00"
    for run in runs:
        day = str(run.get("generated_at", ""))[:10]
        last = max(last, day) if re.fullmatch(r"\d{4}-\d{2}-\d{2}", day) else last
        days.append(last)
    return days


def write_history(path: Path, data: dict) -> None:
    """Writes a behavior history in the layout of its path; a directory gets
    one file per day, and only the files whose text changes are written."""
    text = lambda value: json.dumps(value, ensure_ascii=False, indent=2) + "\n"
    if not history_sharded(path):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text(data), encoding="utf-8")
        return
    groups = {}
    for day, run in zip(history_days(data["runs"]), data["runs"]):
        groups.setdefault(day, []).append(run)
    path.mkdir(parents=True, exist_ok=True)
    for day, runs in groups.items():
        target = path / f"{day}.json"
        content = text({"schema": 1, "runs": runs})
        if not target.is_file() or target.read_text(encoding="utf-8") != content:
            target.write_text(content, encoding="utf-8")
    for old in path.glob("*.json"):
        if old.stem not in groups:
            old.unlink()
    path.with_suffix(".json").unlink(missing_ok=True)


def append_history(path: Path, entry: dict) -> None:
    """Keep the denominator identity beside counts so scope changes stay visible.

    Execution snapshots of a simulator outside SIMULATORS and RETIRED_SIMULATORS
    are dropped from the earlier runs, as tools/results_history.py drops its
    results, and the run records how many were dropped; its counts are left as
    they were measured. An executed list that an earlier snapshot already
    holds is written as a reference to it (compact_history_lists), so the
    history grows only by the lists that changed. An entry with a run_url
    replaces an earlier entry of the same run (a rerun of the workflow).
    The history is one file or a directory of daily files (read_history);
    references may point to a list in an earlier file."""
    data = read_history(path)
    expand_history_lists(data)
    drop_unknown_snapshots(data)
    if entry.get("run_url"):
        # A rerun of a workflow measures the same run again.
        data["runs"] = [r for r in data["runs"] if r.get("run_url") != entry["run_url"]]
    data["runs"].append(entry)
    compact_history_lists(data)
    write_history(path, data)


def summary_data(snapshot: dict, keep_timestamp: bool = False) -> dict:
    """Keep per-item outcomes in the detailed JSON, not every history entry."""
    result = {k: v for k, v in snapshot.items() if k != "generated_at" or keep_timestamp}
    result["execution"] = {"snapshots": [{k: v for k, v in run.items() if k != "outcomes"}
                                         for run in snapshot["execution"]["snapshots"]]}
    return result


def markdown_prose(value: str, clause: str = "") -> str:
    """Render Japanese terminology and literal arrays, preserving inline code."""
    def prose(text):
        # Presentation only: registry text, evidence anchors and hashes stay intact.
        for original, rendered in (
            ("非空成功", "nonvacuous pass"), ("空成功", "vacuous pass"),
            ("違法系テスト", "規格違反テスト"), ("違法系", "規格違反テスト"), ("違法な", "規格に違反する"),
            ("合法な", "規格で認められる"),
            ("並行アサーション", "コンカレントアサーション"),
            ("被覆済み", "カバー済み"), ("被覆率", "カバレッジ"),
        ):
            text = text.replace(original, rendered)
        if clause.split(".")[0] in {"16", "F"}:
            text = re.sub(r"(?<!時)(?<!乱数)系列", "シーケンス", text)
            text = text.replace("性質", "プロパティ")
        return re.sub(r"(?<!\\)([\[\]])", r"\\\1", text)

    pieces, end = [], 0
    for match in re.finditer(r"(`+)(.*?)\1", value, re.DOTALL):
        pieces.append(prose(value[end:match.start()]))
        pieces.append(match[0])
        end = match.end()
    pieces.append(prose(value[end:]))
    return "".join(pieces)


def report(inventory: dict, sections: dict, rows: list, runs: dict, ignored: list,
           source_url: str | None = None, source_audit: dict | None = None,
           denominator_reviewed: bool = False, measured: dict | None = None) -> str:
    stats = summarize(sections, rows, runs, denominator_reviewed)
    total = stats["registered"]
    pct = lambda n: f"{n}/{total} ({100*n/total:.2f}%)" if total else "0/0 (undefined)"
    whole = stats["whole_standard_percent"]
    executed_whole = stats["whole_standard_executed_percent"]
    pending = ("未確定（資料確認済み。解釈保留と要求の重複整理が残る）"
               if source_audit and source_audit["source_review_complete"]
               else "未確定（要求の洗い出しが未完了）")
    link = lambda path: f"{source_url.rstrip('/')}/{path}" if source_url else f"../{path}"
    lines = ["# IEEE 1800-2023 要求カバレッジ", "",
             "`tools/behavior_coverage.py` が `coverage/` の台帳と実行証跡から生成します。",
             f"[集計概要]({link('docs/behavior-coverage-summary.md')}) / "
             f"[全要求の抽出結果]({link('docs/requirement-extraction.md')}) / "
             f"[管理手順]({link('coverage/README.md')}) / "
             f"[節の引用数]({link('docs/coverage-depth.md')})", "",
             f"要求行の対応とPASSの証拠を数えています。[設計と実行の違い]({link('docs/faq.md')}#q16-how-do-design-and-execution-coverage-differ)を読み、テスト本数や一つのツールの一致率と区別してください。", "",
             f"**要求カバレッジ（テスト設計）: {pending if whole is None else f'{whole:.2f}%'}。**",
             "規格要求の実行確認率: " + ("未確定。" if executed_whole is None else
                                 f"Ghostを除いて {100 * stats['executed_reproducible'] / total:.2f}%、"
                                 f"Ghostとkirimasimを含めて {executed_whole:.2f}%。"),
             "節の引用やテスト本数を、全動作の網羅率に換算しません。", "",
             f"- 規格棚卸し: 本文1–41章と附属書A–Q、計 {stats['sections']} 見出し。",
             f"- 規定部分の解釈保留なし: {stats['audited_sections']}/{stats['normative_sections']} 見出し "
             f"({stats['extraction_progress_percent']:.2f}%)。資料確認率・動作網羅率とは別です。",
             f"- 登録済み動作に対する要求カバレッジ（テスト設計）: {pct(stats['mapped'])}。",
             f"- 登録済み動作のうち、現行入力に対応するパス結果の記録があるもの: {pct(stats['executed'])}。",
             f"- 登録済みだがテスト未対応: {stats['unmapped']} 動作。", "",
             "登録済み動作だけの割合は規格全体の割合ではありません。親節の導入本文も独立した",
             "調査対象です。図・表・構文・例外・エラー・他節参照を調べ、要求を分解して初めて",
             "その見出しを完了にできます。ツール依存・未実装は自動的な除外理由になりません。", "",
             f"[要求抽出の解釈・再検討記録]({link('docs/requirement-extraction-notes.md')})も管理します。",
             "登録単位には要求文の出現箇所、条件別の検証項目、初期登録の具体的な観測ケースを含みます。",
             "分母のレビューで意味的な重複を統合し、登録件数を全規格要求数として承認しています。"
             if whole is not None else
             "登録件数は、意味的に重複のない全規格要求数を確定した値ではありません。", "",
             "## 実行証跡", "",
             "成功は対応テストの全期待出力／診断の一致を意味します。`known`、`unsupported`、",
             "`fail`、来歴なし、入力／ランナー変更後の結果は成功に数えません。複数の結果の和集合は",
             "独立した検証環境での確認数であり、一つのシミュレータの適合率ではありません。", ""]
    lines += ["複数テストで一つの要求を分担する `check_groups` は、同じ実行環境・実行回で",
              "グループ内の全テストが成功した場合に限り成功とします。未指定の対応は独立した代替証拠です。", ""]
    if measured:
        provisional = measured["provisional_design_percent"]
        execution_pct = measured["provisional_execution_percent"]
        reproducible_pct = measured["provisional_execution_reproducible_percent"]
        display = lambda value: "未確定" if value is None else f"{value:.2f}%"
        if whole is not None:
            lines[6:6] = [f"**全規格の要求台帳ベース（確定）: 設計 {display(provisional)}、"
                          f"Ghostを除く実行 {display(reproducible_pct)}、"
                          f"Ghostとkirimasimを含む実行 {display(execution_pct)}。**",
                          "解釈保留・未対応を分母に含めます。分母のレビューで意味の重複を統合した値です。", ""]
        else:
            lines[6:6] = [f"**全規格の要求台帳ベース（暫定）: 設計 {display(provisional)}、"
                          f"Ghostを除く実行 {display(reproducible_pct)}、"
                          f"Ghostとkirimasimを含む実行 {display(execution_pct)}。**",
                          "解釈保留・未対応を分母に含めます。意味の重複整理前の値で、以下の確定値とは区別します。", ""]
    if source_audit:
        position = lines.index(f"- 規格棚卸し: 本文1–41章と附属書A–Q、計 {stats['sections']} 見出し。") + 1
        lines[position:position] = [
            f"- 全資料の確認・要求抽出: {source_audit['audited']}/{source_audit['sections_total']} 節 "
            f"({source_audit['source_review_percent']:.2f}%)、"
            f"{source_audit['classified_blocks']}/{source_audit['blocks_total']} 出典ブロックを分類済み。",
            f"- 規定部分の資料確認: {source_audit['normative_reviewed']}/{stats['normative_sections']} 節 "
            f"({source_audit['normative_source_review_percent']:.2f}%)。",
            f"- 解釈保留: {source_audit['interpretation_issues']} 論点、"
            f"{len(source_audit['interpretation_sections'])} 節、"
            f"{source_audit['interpretation_issue_rows']} 登録行。保留を完了・テスト対応済みに数えません。",
        ]
    if not runs["snapshots"]:
        lines.append("採用可能な実行証跡なし。")
    for s in runs["snapshots"]:
        lines.append(f"- `{s['file']}`: {doc_localization.code_span(s['version'])} / "
                     f"{doc_localization.code_span(s['generated_at'])} / "
                     f"{len(s['executed'])}/{total} 動作確認、古い入力との対応 {s['stale_links']} 件。")
    for reason in ignored:
        lines.append(f"- 不採用: {reason}。")
    lines += ["", "## 章・附属書別の調査状態", "",
              "件数は見出しごとの本文の調査状態です。動作数とは異なります。", ""]
    for root in sorted((n for n in sections if "." not in n), key=section_key):
        group = [s for n, s in sections.items() if n == root or n.startswith(root + ".")]
        norm = [s for s in group if s["kind"] == "normative"]
        done = sum(s["review"] in ("complete", "no_behavior") for s in norm)
        rs = [r for r in rows if r["clause"].split(".")[0] == root]
        state = f"解釈保留なし {done}/{len(norm)}" if norm else "参考（規範要件の分母に含めない）"
        lines.append(f"- {root} {sections[root]['title']}: {state}、"
                     f"登録 {len(rs)}、テスト対応 {sum(r['mapped'] for r in rs)}。")
    lines += ["", "## 登録済み動作と観測点", "",
              "`coverage/behaviors.json` には条件・合格基準・根拠・入力ハッシュも記録します。",
              "以下の対応は内容を確認したものだけです。引用だけがあるテストは候補として扱います。", ""]
    lines += ["未対応は台帳上の対応未確認を意味し、既存テストが一切ないという判定ではありません。", ""]
    executed = set(runs["executed"])
    for r in sorted(rows, key=lambda r: (section_key(r["clause"]), r["id"])):
        state = "実行確認あり" if r["id"] in executed else "テスト対応あり・実行未確認" if r["mapped"] else "テスト未対応"
        lines += [f"### {r['id']}", "",
                  f"{doc_localization.code_span(r['clause'])} / {doc_localization.code_span(r['kind'])} / {state}", "",
                  markdown_prose(r["behavior"], r["clause"]), "",
                  f"合格基準: {markdown_prose(r['acceptance'], r['clause'])}", ""]
        if r.get("modality"):
            lines += [f"規定の性質: `{r['modality']}`。", ""]
        if r.get("interpretation_issue"):
            lines += [f"未解決の解釈: `{r['interpretation_issue']}`（対応承認・節完了を保留）。", ""]
        for c in r["checks"]:
            lines.append(f"- [{Path(c['test']).name}]({link(c['test'])}): "
                         f"{markdown_prose(c['observation'], r['clause'])}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    modes = ap.add_mutually_exclusive_group()
    modes.add_argument("--update", action="store_true")
    modes.add_argument("--check", action="store_true")
    ap.add_argument("--results", type=Path, nargs="+", help="replace the saved execution snapshots")
    ap.add_argument("--output", type=Path, default=REPORT)
    ap.add_argument("--source-url", help="repository blob URL for links in an exported report")
    ap.add_argument("--bilingual-export", action="store_true",
                    help="write Japanese and .en.md exports using the registered report translations")
    ap.add_argument("--json", type=Path, help="also write a machine-readable summary")
    ap.add_argument("--summary-output", type=Path, help="compact Markdown; defaults beside the standard report")
    ap.add_argument("--summary-json", type=Path, help="compact JSON; defaults to coverage/behavior-summary.json")
    ap.add_argument("--history", type=Path, help="append counts and denominator identities to history: "
                                                 "a .json file, or a directory of daily files")
    ap.add_argument("--run-url", help="with --history: the workflow run measured; a rerun replaces "
                                      "the entry of its earlier attempt")
    ap.add_argument("--require-complete", action="store_true",
                    help="require an audited whole-standard denominator and all behaviors mapped/executed")
    ap.add_argument("--require-source-reviewed", action="store_true",
                    help="require classified source blocks for every section; does not approve interpretations or tests")
    ap.add_argument("--verify-source", type=Path, help="verify supplied PDF and extracted-text SHA-256")
    ap.add_argument("--test-digest", type=Path, help="print a test fingerprint after manual review")
    ap.add_argument("--candidates", help="list exact-citation test candidates for a section")
    ap.add_argument("--write-baseline", action="store_true")
    ap.add_argument("--reason", help="reason for an intentional baseline change")
    args = ap.parse_args()
    if args.bilingual_export and args.output == REPORT:
        ap.error("--bilingual-export requires a separate --output path")
    summary_output = args.summary_output or (SUMMARY_REPORT if args.output == REPORT else None)
    export_siblings = {REPORT: args.output}
    if summary_output is not None:
        export_siblings[SUMMARY_REPORT] = summary_output

    def markdown_versions(path, content, canonical):
        if args.bilingual_export:
            return doc_localization.export_versions(path, content, canonical,
                       source_url=args.source_url, siblings=export_siblings)
        return doc_localization.versions(path, content)

    if args.test_digest:
        print(suite_results.input_digest(args.test_digest))
        return 0
    try:
        inventory = json.loads((DATA / "standard-sections.json").read_text(encoding="utf-8"))
        registry = json.loads((DATA / "behaviors.json").read_text(encoding="utf-8"))
        sections, rows = validate(inventory, registry)
        import requirement_audit
        audit_stats = requirement_audit.load_and_validate(DATA, inventory, registry)
        if args.candidates:
            require(args.candidates in sections, f"unknown section {args.candidates}")
            candidates = [{"test": t.relative_to(ROOT).as_posix(),
                           "description": suite_results.header(t).get("description", "")}
                          for t in suite_results.find_tests()
                          if args.candidates in suite_results.header(t).get("lrm", "").split()[1:]]
            print(json.dumps(candidates, ensure_ascii=False, indent=2))
            return 0
        current = baseline(sections, rows, inventory["source"])
        current["source_index_sha256"] = audit_stats["source_index_sha256"]
        current["source_reviewed_sections"] = sorted(
            json.loads((DATA / "requirement-audit.json").read_text(encoding="utf-8"))["sections"], key=section_key)
        if args.write_baseline:
            require(bool(args.reason and args.reason.strip()), "--write-baseline requires --reason")
            current["reason"] = args.reason
            (DATA / "behavior-baseline.json").write_text(
                json.dumps(current, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        else:
            previous = json.loads((DATA / "behavior-baseline.json").read_text(encoding="utf-8"))
            check_baseline(previous, current)
            growth = any(previous.get(k) != value for k, value in current.items())
            if growth and args.update:
                (DATA / "behavior-baseline.json").write_text(json.dumps(
                    {**current, "reason": "Monotonic additions of requirements, mappings or "
                     "completed investigations, recorded by --update"},
                    ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            if args.check:
                require(not growth, "baseline does not yet lock new coverage; run --update")
        if args.verify_source:
            source = inventory["source"]
            pdf = args.verify_source / source["pdf"]
            require(hashlib.sha256(pdf.read_bytes()).hexdigest() == source["pdf_sha256"],
                    "the PDF differs from the inventoried standard")
            source_index = json.loads((DATA / "requirement-source-index.json").read_text(encoding="utf-8"))
            layout = args.verify_source / "out/lrm_pdftotext_layout.txt"
            require(hashlib.sha256(layout.read_bytes()).hexdigest() == source_index["text_sha256"],
                    "the extracted text differs from the audited standard")
        runs, ignored = execution(rows, args.results if args.results is not None
                                  else list((DATA / "results").glob("*.json")))
        denominator_reviewed = registry.get("denominator_review", {}).get("state") == "approved"
        stats = summarize(sections, rows, runs, denominator_reviewed)
        measured = measurement(sections, rows, runs, audit_stats, denominator_reviewed,
                               current["inventory_sha256"])
        text = report(inventory, sections, rows, runs, ignored, args.source_url, audit_stats,
                      denominator_reviewed, measured)
        snapshot = {"schema": 1, "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    "inventory_sha256": current["inventory_sha256"],
                    "registry_sha256": hashlib.sha256((DATA / "behaviors.json").read_bytes()).hexdigest(),
                    "source_url": args.source_url,
                    "source_audit": audit_stats,
                    **stats, **measured, "execution": runs, "ignored_results": ignored}
        if args.json:
            executed_ids = set(runs["executed"])
            args.json.parent.mkdir(parents=True, exist_ok=True)
            args.json.write_text(json.dumps({**snapshot,
                                             "requirements": [{"id": r["id"],
                                                               "clause": r["clause"],
                                                               "mapped": r["mapped"],
                                                               "executed": r["id"] in executed_ids,
                                                               "status": requirement_status(r, executed_ids)}
                                                              for r in rows]},
                                            ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        if args.check:
            require(all(path.is_file() and path.read_text(encoding="utf-8") == content
                        for path, content in markdown_versions(args.output, text, REPORT).items()),
                    f"stale report: run python3 tools/behavior_coverage.py --update")
        elif args.update or args.output != REPORT:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            for path, content in markdown_versions(args.output, text, REPORT).items():
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
            print(f"wrote {args.output}")
        else:
            print(text, end="")
        compact = summary_data(snapshot)
        summary_json = args.summary_json or (SUMMARY_JSON if args.output == REPORT else None)
        detail_link = os.path.relpath(args.output, summary_output.parent) if summary_output else args.output.name
        artifacts = [(summary_output, compact_report(compact, args.source_url, detail_link)),
                     (summary_json, json.dumps(compact, ensure_ascii=False, indent=2) + "\n")]
        artifacts = {path: content for path, content in artifacts if path is not None}
        if args.bilingual_export:
            if summary_output is not None:
                artifacts.update(markdown_versions(summary_output, artifacts.pop(summary_output),
                                                   SUMMARY_REPORT))
        else:
            artifacts = doc_localization.expand(artifacts)
        for path, content in artifacts.items():
            if path is None:
                continue
            if args.check:
                require(path.is_file() and path.read_text(encoding="utf-8") == content,
                        f"stale coverage summary: {path}; run --update")
            elif args.update or args.output != REPORT:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
        if args.require_complete:
            require(stats["whole_standard_percent"] == stats["whole_standard_executed_percent"] == 100,
                    "whole-standard denominator is incomplete or behaviors lack tests/fresh passes")
        if args.require_source_reviewed:
            require(audit_stats["source_review_complete"],
                    "some sections lack a complete source-block classification")
        if args.history:
            require(not args.check, "--check cannot append measurement history")
            entry = summary_data(snapshot, keep_timestamp=True)
            if args.run_url:
                entry["run_url"] = args.run_url
            append_history(args.history, entry)
    except (InvalidCoverage, KeyError, TypeError, OSError, ValueError) as exc:
        print(f"behavior coverage: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
