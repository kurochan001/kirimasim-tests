/*
:name: test_illegal_pathpulse_input_bit_select
:description: The input terminal of a path-specific PATHPULSE$ specparam cannot be a bit-select of a vector, while the entire vector port is legal (IEEE 1800-2023 Section 30.7.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the PATHPULSE$ specparam for the path from b to y names the bit-select b[0] as its input terminal
:expected_stderr_regex: test_illegal_pathpulse_input_bit_select\.sv:26:
*/
// IEEE 1800-2023 §30.7.1: the input and output terminals named in a
// path-specific PATHPULSE$ specparam follow the rules for module path inputs
// and outputs, except that they shall not be a bit-select or part-select of a
// vector. The specparam for the path from a to y names the vector port a,
// which is legal. The one for the path from b to y names b[0].

module ppb_cell(input wire [1:0] a, input wire [1:0] b, output wire y);
  assign y = a[0] ^ b[0];
  specify
    (a *> y) = 4;
    (b *> y) = 4;
    specparam PATHPULSE$a$y = (1, 2);
    specparam PATHPULSE$b[0]$y = (1, 2);   // illegal: bit-select as the input terminal
  endspecify
endmodule

module test_illegal_pathpulse_input_bit_select;
  logic [1:0] a = 2'b01, b = 2'b00;
  wire y;
  ppb_cell u (.a(a), .b(b), .y(y));
  initial #10 $display("%b", y);
endmodule
