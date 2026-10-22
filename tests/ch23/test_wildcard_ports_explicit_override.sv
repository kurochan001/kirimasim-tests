/*
:name: test_wildcard_ports_explicit_override
:description: An explicit named connection takes precedence over a wildcard implicit connection (IEEE 1800-2023 Section 23.3.2.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wildcard_ports_explicit_override.expected
*/
// IEEE 1800-2023 23.3.2.3: A same-named local input must not replace the
// explicit constant connection, while the output is connected by the wildcard.

module wildcard_leaf(input [3:0] data, output [3:0] result);
  assign result = ~data;
endmodule
module test_wildcard_ports_explicit_override;
  bit [3:0] data = 3;
  wire [3:0] result;
  wildcard_leaf u(.data(4'hc), .*);
  initial #1 $display("local=%h result=%h", data, result);
endmodule
