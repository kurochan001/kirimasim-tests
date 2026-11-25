/*
:name: test_protect_license_matches_without_release
:description: protect license matching without an optional release callback
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.4 34.5.28.2 34.5.29.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_protect_license_matches_without_release
:expected_stdout: no release body=62
*/
`timescale 1ns/1ns
`pragma protect begin
`pragma protect decrypt_license=(library="dec",entry="check",feature="allow",match=37)
`pragma protect runtime_license=(library="run",entry="check",feature="allow",match=0)
module protect_license_no_release(output wire [7:0] value);
  assign value = 8'd62;
endmodule
`pragma protect end

module test_protect_license_matches_without_release;
  wire [7:0] value;
  protect_license_no_release body(value);
  initial begin
    #1 $display("no release body=%0d", value);
    $finish;
  end
endmodule
