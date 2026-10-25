/*
:name: test_syntax_continuous_assign_forms
:description: a continuous assignment to nets with a drive strength, three delays and two net assignments, and one to variables with a delay control and two variable assignments (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.3.2 10.3.3 10.3.4 28.16 A.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_continuous_assign_forms.expected
*/
// IEEE 1800-2023 §10.3, A.6.1: a continuous assignment to nets is assign,
// an optional drive strength, an optional delay of up to three values and
// one or more net assignments separated by commas; one to variables is
// assign, an optional delay control and one or more variable assignments.
// §10.3.4: the strength applies to the 0 and 1 the assignment drives.
// §10.3.3, §28.16: with three delays the first is the delay of a change to
// 1, the second of a change to 0 and the third of a change to z; the delay
// control of a variable assignment delays every update of the variable.
//
// n1 and n2 are assigned with (weak0, strong1) and #(2, 4, 6), and v1 and v2
// with #7. The values are printed with %v and %0d before and after each
// delay: n1 rises and then falls, n2 rises and then turns off.

`timescale 1ns/1ns

module test_syntax_continuous_assign_forms;
  reg a, b, en;
  int cnt;
  wire n1, n2;
  logic [7:0] v1;
  logic v2;

  assign (weak0, strong1) #(2, 4, 6) n1 = a & b, n2 = en ? a : 1'bz;
  assign #7 v1 = cnt + 1, v2 = ~b;

  initial begin
    a = 1; b = 1; en = 1; cnt = 5;
    #3 $display("t=%0t n1=%v n2=%v", $time, n1, n2);
    #3 $display("t=%0t v1=%0d v2=%b", $time, v1, v2);
    #2 $display("t=%0t v1=%0d v2=%b", $time, v1, v2);
    #2 b = 0; en = 0; cnt = 9;    // t=10
    #3 $display("t=%0t n1=%v n2=%v v1=%0d v2=%b", $time, n1, n2, v1, v2);
    #2 $display("t=%0t n1=%v n2=%v v1=%0d v2=%b", $time, n1, n2, v1, v2);
    #3 $display("t=%0t n1=%v n2=%v v1=%0d v2=%b", $time, n1, n2, v1, v2);
  end
endmodule
