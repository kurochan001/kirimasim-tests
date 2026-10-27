/*
:name: test_35_rest_noncontext_export_error
:description: An imported subroutine that is not declared context aborts the run when it calls an exported SystemVerilog function, because its call chain carries no scope (IEEE 1800-2023 Sections 35.5.3 and 35.5.1.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 35.5.1.3 35.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_35_rest_noncontext_export_error.c
:expected_exit: nonzero
:expected_stderr_regex: Testbench C called 'sv_add' but scope wasn't set
:expected_stdout_verilator: @test_35_rest_noncontext_export_error.expected
*/
// IEEE 1800-2023 §35.5.3: only calls of context imports are instrumented with
// a scope, and a noncontext import shall not call an exported SystemVerilog
// subroutine; 35.5.1.3 says such a call is an error whose effects are
// unpredictable.
//
// The import c_nc_chain is not declared context and calls the exported sv_add.
// The tool Verilator 5.052 stops the run with an error that names the missing
// scope and cites 35.5.3, so the noncontext call chain is seen to have no
// context. The design prints "start" before the call; the diagnostic of the
// tool is sent to standard error by the C code so that the test's standard
// output holds only the design's own line.
//
// The error text is the tool's, not a value the standard fixes; the expected
// standard error is only checked for the phrase that names the missing scope
// and the export sv_add.

module test_35_rest_noncontext_export_error;
  import "DPI-C" function int c_nc_chain(input int v);

  export "DPI-C" function sv_add;

  function int sv_add(input int v);
    return v + 1;
  endfunction

  initial begin
    $display("start");
    $display("noncontext %0d", c_nc_chain(5));
  end
endmodule
