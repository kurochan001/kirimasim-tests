/*
:name: test_vpi_callsite_argument_and_scope_context
:description: A VPI system task retrieves the actual argument and surrounding variable in each call site's scope, distinct from the argument declaration scope (IEEE 1800-2023 Sections 38.18 and H.9.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.18 H.9.1 37.42 38.21 38.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_callsite_argument_and_scope_context.c
:expected_stdout: @test_vpi_callsite_argument_and_scope_context.expected
*/
// H.9.1 B005 associates VPI context with the system task call site.
// The same registered task is called from two instances at distinct times.
// Both arguments are declared at module scope in the parent, while each
// call-site instance has its own local_value. The parent's local_value is
// a contrasting decoy. The application gets the current call's scope, the
// actual argument and a variable looked up relative to that scope. Full
// names and differing values distinguish call-site scope from argument-owner
// or root scope. String properties are copied before another vpi_get_str
// call (38.11).

`timescale 1ns/1ns
module callsite_context_left;
  int local_value = 7;
  initial #1 $vt_callsite_context(test_vpi_callsite_argument_and_scope_context.left_arg);
endmodule

module callsite_context_right;
  int local_value = 19;
  initial #2 $vt_callsite_context(test_vpi_callsite_argument_and_scope_context.right_arg);
endmodule

module test_vpi_callsite_argument_and_scope_context;
  int left_arg = 41, right_arg = 62;
  int local_value = 101;
  callsite_context_left left();
  callsite_context_right right();
endmodule
