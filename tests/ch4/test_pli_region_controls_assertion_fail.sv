/*
:name: test_pli_region_controls_assertion_fail
:description: A failing Observed property uses the old sample and still schedules its reactive action
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.1 4.4.2.5 4.4.3.1 4.4.3.5 4.4.3.6 4.4.3.7 4.4.3.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @pli_control_fixtures/region_trace.c
:files: pli_control_fixtures/phase_slot.svh
:expected_stdout: @test_pli_region_controls_assertion_fail.expected
*/
`define RC_TICK 6
`define RC_INITIAL 11
`define RC_ACTIVE 23
`define RC_NBA 37
`define RC_RENBA 19
`define RC_PROPERTY 23
`include "phase_slot.svh"
