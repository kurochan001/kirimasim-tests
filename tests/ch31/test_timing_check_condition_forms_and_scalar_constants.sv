/*
:name: test_timing_check_condition_forms_and_scalar_constants
:description: A timing check condition is a scalar condition in or out of parentheses, which is an expression, its inversion, or its comparison by ==, ===, != or !== with one of the ten spellings of 0 or 1, and only checks whose condition is true report a violation (IEEE 1800-2023 Sections 31.7 and A.7.5.3)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.7 A.7.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_check_condition_forms_and_scalar_constants.expected
*/
// IEEE 1800-2023 A.7.5.3, Syntax 31-2: timing_check_condition is
// scalar_timing_check_condition, which may be in parentheses, and
// scalar_timing_check_condition is an expression, ~ expression, or an
// expression compared by ==, ===, != or !== with a scalar_constant. The
// scalar_constant spellings are 1'b0, 1'b1, 1'B0, 1'B1, 'b0, 'b1, 'B0, 'B1, 1
// and 0. §31.7: the check applies only when its condition is true; a false
// condition makes the check ignore the event.
//
// The cell tc_condition has twelve $setup checks on the same clock and data,
// each with its own notifier. The conditions cover the plain expression in
// parentheses, its inversion, and ==, ===, != and !== with each of the ten
// scalar constants, some parenthesized and some not. With en = 1 the checks 1,
// 3, 5, 8, 10 and 11 are true, so they report the violation at 10; with en = 0
// the checks 2, 4, 6, 7, 9 and 12 are true, so they report the violation at
// 30. Each notifier toggles from 0 to 1 once, and the test prints all of them
// after each of the two edges, so a wrong spelling leaves its notifier 0.

`timescale 1ns/1ns

module tc_condition (input wire clk, input wire d, input wire en);
  reg n1 = 1'b0, n2 = 1'b0, n3 = 1'b0, n4 = 1'b0, n5 = 1'b0, n6 = 1'b0;
  reg n7 = 1'b0, n8 = 1'b0, n9 = 1'b0, n10 = 1'b0, n11 = 1'b0, n12 = 1'b0;
  specify
    $setup(d, posedge clk &&& (en), 3, n1);
    $setup(d, posedge clk &&& ~en, 3, n2);
    $setup(d, posedge clk &&& en == 1'b1, 3, n3);
    $setup(d, posedge clk &&& en == 1'b0, 3, n4);
    $setup(d, posedge clk &&& (en === 1'B1), 3, n5);
    $setup(d, posedge clk &&& en === 1'B0, 3, n6);
    $setup(d, posedge clk &&& en != 'b1, 3, n7);
    $setup(d, posedge clk &&& (en != 'b0), 3, n8);
    $setup(d, posedge clk &&& en !== 'B1, 3, n9);
    $setup(d, posedge clk &&& (en !== 'B0), 3, n10);
    $setup(d, posedge clk &&& en == 1, 3, n11);
    $setup(d, posedge clk &&& (en == 0), 3, n12);
  endspecify
endmodule

module test_timing_check_condition_forms_and_scalar_constants;
  reg clk = 1'b0, d = 1'b0, en = 1'b1;

  tc_condition u (.clk(clk), .d(d), .en(en));

  initial begin
    #8  d = 1'b1;
    #2  clk = 1'b1;     // 10: the true conditions report
    #2;
    $display("t=%0t n1=%b n2=%b n3=%b n4=%b n5=%b n6=%b", $time,
             u.n1, u.n2, u.n3, u.n4, u.n5, u.n6);
    $display("t=%0t n7=%b n8=%b n9=%b n10=%b n11=%b n12=%b", $time,
             u.n7, u.n8, u.n9, u.n10, u.n11, u.n12);
    #3  clk = 1'b0;
    #5  en = 1'b0;
    #8  d = 1'b0;
    #2  clk = 1'b1;     // 30: the other conditions report
    #2;
    $display("t=%0t n1=%b n2=%b n3=%b n4=%b n5=%b n6=%b", $time,
             u.n1, u.n2, u.n3, u.n4, u.n5, u.n6);
    $display("t=%0t n7=%b n8=%b n9=%b n10=%b n11=%b n12=%b", $time,
             u.n7, u.n8, u.n9, u.n10, u.n11, u.n12);
    $finish;
  end
endmodule
