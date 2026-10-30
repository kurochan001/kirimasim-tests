/*
:name: test_assume_property_actions
:description: simulation checks an assume property: its pass statement runs when the property is true and its fail statement when it is false, neither runs for a disabled evaluation, the action control tasks suppress them, and without an else clause a failure calls $error unless fail actions are off; a restrict property is not checked in simulation (IEEE 1800-2023 Section 16.14.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.2 16.14.4 20.11 20.10 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assume_property_actions.expected
:expected_stderr_regex: (?i)\A(?=[\s\S]*(?:error[^\n]*(?:\n[^\n]*)?test_assume_property_actions\.sv:41\b|test_assume_property_actions\.sv:41\b[^\n]*(?:\n[^\n]*)?error))(?![\s\S]*test_assume_property_actions\.sv:42\b)(?![\s\S]*test_assume_property_actions\.sv:44\b)
*/
// IEEE 1800-2023 §16.14.2: in simulation an assumed property is checked like
// an asserted one and reported when it fails: the pass statement runs when it
// is true, the fail statement when it is false, and neither when the
// evaluation is disabled (§16.12); the action control tasks of §20.11 control
// them. A null statement may stand for no action, and without an else clause
// a failure calls $error (§20.10: the message names the file and line) unless
// fail actions are turned off. §16.14.4: restrict property is not verified in
// simulation. The table in the code gives the inputs of each tick (5 to 75).
// u_pf passes at 5 and, vacuously, at 45, and fails at 15 and 75; it is
// disabled at 25 and 35; the pass and fail actions are off from 50 to 70.
// u_def (line 41) fails at 15 and has to be reported with an error; u_off
// (line 42) fails only at 65, while fail actions are off, and must not be
// reported. u_null leaves out its pass statement, as A.6.3 allows before else
// (a null statement cannot stand there). r_chk (line 44) is violated at 15 and
// 65 but must not be reported. Wording and layout of messages are not compared.

`timescale 1ns/1ns

module test_assume_property_actions;
  logic clk = 0, go = 0, x = 0, rst = 0, g_def = 0, g_off = 0, g_null = 0, g_r = 0;
  int f_null = 0;
  int p_q[$], f_q[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  u_pf: assume property (@(posedge clk) disable iff (rst) go |-> x) p_q.push_back($time);
    else f_q.push_back($time);
  u_def: assume property (@(posedge clk) g_def |-> x);
  u_off: assume property (@(posedge clk) g_off |-> x);
  u_null: assume property (@(posedge clk) g_null |-> x) else f_null++;
  r_chk: restrict property (@(posedge clk) g_r |-> x);

  // Sets the values sampled at the next tick.
  task automatic tick(logic [7:0] v);
    {go, x, rst, g_def, g_off, g_null, g_r} = v[6:0];
    #10;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    //      go x rst g_def g_off g_null g_r
    tick(8'b0_1_1_0_0_0_0_0);   // 5
    tick(8'b0_1_0_0_1_0_1_1);   // 15
    tick(8'b0_1_0_1_0_0_0_0);   // 25
    tick(8'b0_1_1_1_0_0_0_0);   // 35
    tick(8'b0_0_0_0_0_0_0_0);   // 45
    $assertpassoff;
    $assertfailoff;
    tick(8'b0_1_1_0_0_0_0_0);   // 55
    tick(8'b0_1_0_0_0_1_0_1);   // 65
    $assertpasson;
    $assertfailon;
    tick(8'b0_1_0_0_0_0_0_0);   // 75
    $display("u_pf passes%s; failures%s", times(p_q), times(f_q));
    $display("u_null failures %0d", f_null);
    $finish;
  end
endmodule
