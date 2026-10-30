/*
:name: test_expect_wait_order_default_error_failoff
:description: a failing expect statement or wait_order without an else clause calls $error by default; $assertcontrol FailOff (9) stops the default $error and the else clause of expect statements until FailOn (8), but not those of wait_order (IEEE 1800-2023 Sections 20.10 and 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.10 20.11 16.17 15.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expect_wait_order_default_error_failoff.expected
:expected_stderr_regex: \A(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:50\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:51\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:52\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:53\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:54\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:55\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:58\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:59\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:60\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:61\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:62\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:63\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:66\b)(?=[\s\S]*test_expect_wait_order_default_error_failoff\.sv:67\b)(?![\s\S]*test_expect_wait_order_default_error_failoff\.sv:68\b)
*/
// IEEE 1800-2023 §20.10: when the action block of an expect statement
// (§16.17) or a wait_order (§15.5.4) has no else clause, its fail action is
// a call to $error, whose message gives the file and line; for expect
// statements, though not for wait_order, $assertcontrol with control_type 9
// (FailOff) suppresses it. §20.11: FailOff stops the fail actions of the
// selected expect statements, the default $error included, until
// control_type 8 (FailOn).
// Every statement below fails and is on its own line: each expect waits for
// the next clock tick, where z is 0; each wait_order waits for e1 and then e2,
// and e2 is triggered first. The forms are: no action block, a pass statement
// only, and an else clause, which counts in place of the $error. The regular
// expression requires a message from the lines where the default $error has
// to run and none from the others: expect and wait_order lines before
// FailOff, only the wait_order lines after it, and the expect lines again
// after FailOn. No else-clause line ever reports; the else clause of the
// expect statement does not count under FailOff, that of wait_order does.
// The layout of the message is the tool's (20.10), so file:line of a
// statement may be followed by a space or any punctuation, not only a colon.
// Neither simulator runs this test: Icarus Verilog 13.0 and release 5.052 of
// the Verilator tool support neither expect nor wait_order.

`timescale 1ns/1ns

module test_expect_wait_order_default_error_failoff;
  logic clk = 0, z = 0;
  event e1, e2;
  int passes = 0, ex_fails = 0, wo_fails = 0;

  always #5 clk = ~clk;

  task automatic show(string name);
    $display("%s: pass statements %0d, expect else %0d, wait_order else %0d",
             name, passes, ex_fails, wo_fails);
  endtask

  initial begin
    expect (@(posedge clk) z);
    expect (@(posedge clk) z) passes++;
    expect (@(posedge clk) z) else ex_fails++;
    fork wait_order (e1, e2); #1 ->e2; join
    fork wait_order (e1, e2) passes++; #1 ->e2; join
    fork wait_order (e1, e2) else wo_fails++; #1 ->e2; join
    show("default");
    $assertcontrol(9);
    expect (@(posedge clk) z);
    expect (@(posedge clk) z) passes++;
    expect (@(posedge clk) z) else ex_fails++;
    fork wait_order (e1, e2); #1 ->e2; join
    fork wait_order (e1, e2) passes++; #1 ->e2; join
    fork wait_order (e1, e2) else wo_fails++; #1 ->e2; join
    show("failoff");
    $assertcontrol(8);
    expect (@(posedge clk) z);
    expect (@(posedge clk) z) passes++;
    expect (@(posedge clk) z) else ex_fails++;
    show("failon");
    $finish;
  end
endmodule
