/*
:name: test_pli_region_controls_assertion_pass
:description: A passing Observed property follows active updates and precedes reactive feedback
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.1 4.4.2.5 4.4.3.1 4.4.3.5 4.4.3.6 4.4.3.7 4.4.3.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @pli_control_fixtures/region_trace.c
:files: pli_control_fixtures/phase_slot.svh
:expected_stdout: @test_pli_region_controls_assertion_pass.expected
*/
`define RC_TICK 10
`define RC_INITIAL 0
`define RC_ACTIVE 1
`define RC_NBA 2
`define RC_RENBA 5
`define RC_PROPERTY 0
`include "phase_slot.svh"
