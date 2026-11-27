/*
:name: test_negative_setuphold_delayed_condition_roles
:description: Negative setuphold limits sample the conditions in delayed edge order
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9 31.9.2 31.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: negative_timing_fixtures/condition_edges.svh
:expected_stdout: @test_negative_setuphold_delayed_condition_roles.expected
*/
`define TCK_SETUPHOLD
`include "condition_edges.svh"
