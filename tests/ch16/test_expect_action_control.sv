/*
:name: test_expect_action_control
:description: an expect statement without else calls $error when its property fails, unless fail actions are turned off; its fail and pass statements run on failure and success only while the assertion action control tasks leave them enabled (IEEE 1800-2023 Section 16.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.17 20.11 20.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expect_action_control.expected
:expected_stderr_regex: (?i)\A(?=[\s\S]*error[^\n]*test_expect_action_control\.sv:40:)(?![\s\S]*test_expect_action_control\.sv:44:)
*/
// IEEE 1800-2023 §16.17: when the property of an expect fails, its else
// statement runs, and without an else clause the tool calls $error unless
// $assertcontrol suppresses the failure; when it succeeds, its pass statement
// runs; the action control tasks of §20.11 control both. §20.11:
// $assertfailoff and $assertpassoff stop the fail and pass actions of
// assertions and expect statements, including the default $error, until
// $assertfailon and $assertpasson. §20.10: the message of $error names the
// file and line. Each expect starts its evaluation at the tick after it is
// executed; a is always low, so expect (a) fails and expect (!a) passes at
// that tick, and the next statement runs in the same time step. The expect
// without else at line 40 fails at 5 and has to be reported with an error;
// the one at line 44 fails at 25 while fail actions are off and must not be
// reported. The statements that may not run would print the lines that the
// expected output lacks. The wording of the messages is not compared.
// Icarus Verilog 13.0 and the 5.052 release of Verilator do not support
// expect.

`timescale 1ns/1ns

module test_expect_action_control;
  logic clk = 0, a = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  initial begin
    #1;
    expect (@(posedge clk) a);
    $display("%0d: after the expect without else", $time);
    $assertfailoff;
    expect (@(posedge clk) a) else $display("%0d: fail statement while off", $time);
    expect (@(posedge clk) a);
    $display("%0d: after the expects with fail actions off", $time);
    $assertfailon;
    expect (@(posedge clk) a) else $display("%0d: fail statement after FailOn", $time);
    expect (@(posedge clk) !a) $display("%0d: pass statement", $time);
    $assertpassoff;
    expect (@(posedge clk) !a) $display("%0d: pass statement while off", $time);
    $display("%0d: after the expect with pass actions off", $time);
    $assertpasson;
    expect (@(posedge clk) !a) $display("%0d: pass statement after PassOn", $time);
    $finish;
  end
endmodule
