/*
:name: test_protect_license_checks_before_processing_and_execution
:description: protect license entry and release before processing and execution
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.28.2 34.5.29.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_license_checks_before_processing_and_execution
:expected_stdout: licensed body=37
*/
`timescale 1ns/1ns
`pragma protect begin
`pragma protect decrypt_license=(library="dec",entry="check",feature="allow",exit="done",match=37)
`pragma protect runtime_license=(library="run",entry="check",feature="allow",exit="done",match=0)
module protect_license_granted(output wire [7:0] value);
  assign value = 8'd37;
endmodule
`pragma protect end

module test_protect_license_checks_before_processing_and_execution;
  wire [7:0] value;
  protect_license_granted body(value);
  initial begin
    #1 $display("licensed body=%0d", value);
    $finish;
  end
endmodule
