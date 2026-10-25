/*
:name: test_format_upper_lower_name_strength_time
:description: %m and %M print the hierarchical name, %v and %V the strength of a net and %t and %T the time, the uppercase letter selecting the same format as the lowercase one (IEEE 1800-2023 Section 21.2.1.1)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1 21.2.1.4 21.2.1.5 20.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_format_upper_lower_name_strength_time.expected
*/
// IEEE 1800-2023 §21.2.1.1, Table 21-1: %m or %M displays the hierarchical
// name, %v or %V the strength of a net and %t or %T the time in the current
// time format; the two letters of each pair select the same format.
// §21.2.1.5: %m takes no argument and names the scope that calls the task.
// §21.2.1.4: %v gives two strength characters and the value, such as Pu1
// for a pull 1, Su0 for a supply 0, We0 for a weak 0 and HiZ for an undriven
// net. With the default $timeformat (§20.4.3) and only `timescale 1ns/1ns,
// %t shows 5 ns as 5 in a field of 20 characters.
// Every line prints each value once with the lowercase and once with the
// uppercase letter, from the top module and from the instance u1 of sub.

`timescale 1ns/1ns

module sub_upper_lower;
  initial #1 $display("[%m][%M]");
endmodule

module test_format_upper_lower_name_strength_time;
  wire (pull0, pull1) pw = 1'b1;
  supply0 sg;
  wire (weak0, weak1) ww = 1'b0;
  tri nd;

  sub_upper_lower u1();

  initial begin
    #5;
    $display("[%m][%M]");
    $display("[%v][%V][%v][%V]", pw, pw, sg, sg);
    $display("[%v][%V][%v][%V]", ww, ww, nd, nd);
    $display("[%t][%T]", $time, $time);
  end
endmodule
