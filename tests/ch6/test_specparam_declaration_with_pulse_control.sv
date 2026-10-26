/*
:name: test_specparam_declaration_with_pulse_control
:description: a specparam declaration takes an optional packed dimension, a list of mintypmax assignments and the pulse-control form inside a specify block
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_declaration_with_pulse_control.expected
*/
// IEEE 1800-2023 6.20.1: specparam_declaration is the keyword specparam, an
// optional packed_dimension, and a semicolon-terminated
// list_of_specparam_assignments. Each assignment is either a constant
// min:typ:max expression or a pulse_control_specparam. The test declares a
// ranged specparam, a list whose second entry is a mintypmax expression, and a
// PATHPULSE$ pulse-control specparam in a specify block, then prints the
// values. A tool that lacks the pulse-control alternative cannot elaborate
// the specify block; one that ignores the declared range prints another
// narrow value.

module test_specparam_declaration_with_pulse_control;
  parameter int P = 4;
  specparam [3:0] NARROW = 4'hF;
  specparam WIDE = 8'h96, TYP = 1:2:3;

  specify
    specparam PATHPULSE$ = (1, 2);
  endspecify

  initial
    $display("narrow=%0d wide=%0d typ=%0d p=%0d", NARROW, WIDE, TYP, P);
endmodule
