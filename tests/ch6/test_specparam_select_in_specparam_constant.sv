/*
:name: test_specparam_select_in_specparam_constant
:description: the constant expression of a specparam may use an earlier specparam as a constant primary, whole or with a bit-select, a part-select or an indexed part-select (IEEE 1800-2023 Section A.8.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.5 A.8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_select_in_specparam_constant.expected
*/
// IEEE 1800-2023 §A.8.4: a constant primary may be a specparam identifier,
// optionally followed by a bracketed constant range expression, which is a
// single index or a part-select range. §6.20.5: a specparam declared in the
// module body is declared before it is referenced, its value is a constant
// expression, which may use earlier specparams, and a specparam may be read
// in other expressions that are not assigned to a parameter.
//
// SP is the 16-bit specparam 16'ha5c3 (bits 15 to 0: 1010 0101 1100 0011).
// The later specparams take it whole (a5c3), with the part-select [7:0]
// (c3), with the indexed part-select [8 +: 4] (5), and with the bit-selects
// [1] (1) and [2] (0); SP_B1 and SP_B2 have no range, so they take the range
// of their 1-bit values (6.20.5) and %b prints one digit. Each value is
// printed in an initial procedure; a select counted from the wrong end or a
// range taken as a single index would print other values. Verilator 5.054
// prints the right values, but 64 binary digits for SP_B1 and SP_B2.

module test_specparam_select_in_specparam_constant;
  specparam [15:0] SP = 16'ha5c3;
  specparam [15:0] SP_WHOLE = SP;
  specparam [7:0] SP_LOW = SP[7:0];
  specparam [3:0] SP_IDX = SP[8 +: 4];
  specparam SP_B1 = SP[1];
  specparam SP_B2 = SP[2];

  initial begin
    $display("whole %h, [7:0] %h, [8 +: 4] %h", SP_WHOLE, SP_LOW, SP_IDX);
    $display("[1] %b, [2] %b", SP_B1, SP_B2);
  end
endmodule
