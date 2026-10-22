/*
:name: test_nonansi_renamed_concatenated_ports
:description: A non ANSI module port can expose a concatenation under an external port name (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.2.1 23.2.3 23.2.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nonansi_renamed_concatenated_ports.expected
*/
// IEEE 1800-2023 23.2.2.1 23.2.3 23.2.4: The external port expression splits an
// input bus into two body-declared ports; the output reorders the internal
// fields without changing the external naming.
// Oracle checks: The 5.052 release does not build this case.

module renamed_leaf(.bus({hi, lo}), .result(out));
  input [1:0] hi, lo;
  output [3:0] out;
  assign out = {lo, hi};
endmodule
module test_nonansi_renamed_concatenated_ports;
  wire [3:0] result;
  renamed_leaf u(.bus(4'b1001), .result(result));
  initial #1 $display("result=%b width=%0d", result, $bits(u.hi) + $bits(u.lo));
endmodule
