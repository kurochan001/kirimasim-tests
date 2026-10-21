/*
:name: test_vpi_assertion_immediate_handles
:description: VPI finds the immediate assert, assume and cover statements among all assertions, with their kind and their names (IEEE 1800-2023 Sections 39.3.1 and 39.3.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.3.1 39.3.2 37.49 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_immediate_handles.c
:expected_stdout: @test_vpi_assertion_immediate_handles.expected
*/
// IEEE 1800-2023 §39.3.1: vpi_iterate(vpiAssertion, NULL) gives every
// assertion of the design, including immediate assertions. §39.3.2, §37.49:
// an immediate assert, assume and cover has the type vpiImmediateAssert,
// vpiImmediateAssume and vpiImmediateCover, and its vpiName is the statement
// label. §16.3: the three statements run, and the application lists their
// handles from the call of $vt_list. The order of vpi_scan is not relied on:
// the application sorts the names.

module test_vpi_assertion_immediate_handles;
  initial begin
    a1: assert (1);
    a2: assume (1);
    a3: cover (1);
    $vt_list;
    $finish;
  end
endmodule
