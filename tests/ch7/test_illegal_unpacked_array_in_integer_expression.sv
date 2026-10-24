/*
:name: test_illegal_unpacked_array_in_integer_expression
:description: a packed array can be used as an integer in an expression but an unpacked array cannot (IEEE 1800-2023 Section 7.4.6)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array u is used as an integer operand of + in u + 3
:expected_stderr_regex: test_illegal_unpacked_array_in_integer_expression\.sv:29:
*/
// IEEE 1800-2023 §7.4.6: assignment from an integer and use as an integer
// in an expression can be done on packed arrays but not on unpacked arrays.
// The packed arrays p and q are operands of + and the legal design prints
// the sums, as well as the sum of an element of the unpacked array u; the
// last expression adds 3 to the whole unpacked array u.
// The 5.052 release accepts the expression u + 3.

module test_illegal_unpacked_array_in_integer_expression;
  bit [7:0] p = 8'd5;
  bit [1:0][3:0] q = 8'h12;
  bit [7:0] u [2] = '{8'd7, 8'd9};
  int k;
  initial begin
    k = p + 3;
    $display("%0d %0d %0d", k, q + 1, u[1] + 3);
    k = u + 3;   // illegal: unpacked array as an integer operand
  end
endmodule
