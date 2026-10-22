/*
:name: test_dpi_import_calls_exported_value
:description: A context imported function can call an exported SystemVerilog function and return its result (IEEE 1800-2023 Section 13.6)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.6 35.5.1.3 35.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_import_calls_exported_value.c
:expected_stdout: @test_dpi_import_calls_exported_value.expected
*/
// IEEE 1800-2023 13.6 35.5.1.3 35.7: This exercises the round trip across the
// foreign boundary, including the SystemVerilog side effect, rather than only a
// direct C arithmetic call.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_dpi_import_calls_exported_value;
  import "DPI-C" context function int c_fetch();
  export "DPI-C" function sv_value;
  int calls;
  function int sv_value(); calls++; return 23; endfunction
  initial begin
    $display("result=%0d", c_fetch());
    $display("calls=%0d", calls);
  end
endmodule
