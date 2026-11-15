/*
:name: test_illegal_based_literal_zero_size
:description: The size constant of a based literal has to be a nonzero unsigned decimal number, so the literal 0'd1 is an error (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the based literal 0'd1 has the size 0
:expected_stderr_regex: test_illegal_based_literal_zero_size\.sv:29:
*/
// IEEE 1800-2023 §5.7.1: the first token of a based literal, the size
// constant, gives its exact number of bits and shall be a nonzero unsigned
// decimal number; the size of A.8.7 is a non_zero_unsigned_number. The
// literal 1'd1 assigned to a has the size 1 and is legal; the literal 0'd1
// assigned to b has the size 0, which is the error. With 1'd1 in its place
// the design is legal and prints 1 1.
// Icarus Verilog 13.0 reports on the line of the error that a sized
// constant needs a size greater than zero. The 5.054 release of Verilator
// accepts the design.

module test_illegal_based_literal_zero_size;
  logic [7:0] a, b;

  initial begin
    a = 1'd1;
    b = 0'd1;   // illegal: the size of a based literal cannot be 0
    $display("%0d %0d", a, b);
  end
endmodule
