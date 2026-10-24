/*
:name: test_illegal_part_select_variable_width
:description: the width of a part-select has to be constant, while its position can be variable (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the indexed part-select v[i +: w] has the variable width w
:expected_stderr_regex: test_illegal_part_select_variable_width\.sv:25:
*/
// IEEE 1800-2023 §7.4.5: the size of a part-select or slice shall be
// constant, but its position can be variable. The part-selects v[i +: 3]
// and v[i -: 2] start at the variable i and have constant widths, and the
// legal design prints them; the last part-select has the variable width w.

module test_illegal_part_select_variable_width;
  logic [7:0] v = 8'b1011_0110;
  int i = 2;
  int w = 3;
  initial begin
    $display("%b %b", v[i +: 3], v[i -: 2]);
    $display("%b", v[i +: w]);   // illegal: variable width
  end
endmodule
