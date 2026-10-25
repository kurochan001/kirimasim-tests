/*
:name: test_concurrent_assert_actions
:description: a concurrent assert runs its pass statement when its property is true, its fail statement when it is false and neither when the evaluation is disabled, in the Reactive region after the nonblocking updates of the tick; the action control tasks suppress them; without an else clause a failure calls $error unless fail actions are off, a null pass statement is allowed, and severity tasks in a fail statement report with their own severity (IEEE 1800-2023 Section 16.14.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.1 16.3 20.10 20.11 4.4.2 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concurrent_assert_actions.expected
:expected_stderr_regex: (?i)\A(?=[\s\S]*error[^\n]*test_concurrent_assert_actions\.sv:48:)(?![\s\S]*test_concurrent_assert_actions\.sv:49:)(?=[\s\S]*warn[^\n]*test_concurrent_assert_actions\.sv:51:)(?=[\s\S]*a_warn tick 2)(?=[\s\S]*a_info tick 2)
*/
// IEEE 1800-2023 §16.14.1: when the property of an assert is true its pass
// statement runs, when it is false its fail statement runs, and when the
// evaluation is disabled (§16.12) neither runs; the action control tasks of
// §20.11 control them. A null statement may stand for no action, and without
// an else clause a failure calls $error unless fail actions are turned off.
// The conventions of §16.3 hold: the default severity is error, and severity
// tasks may be used in the action block (§20.10: the message names the
// severity and the file and line of the call, and includes the user text).
// The pass and fail statements run in the Reactive region, so after the NBA
// region (§4.4.2) where n has been increased at that tick: they see n = k at
// the k-th tick. The table in the code gives the inputs of each tick. a_pf
// passes at ticks 1 and 5 (vacuously at 5) and fails at 2 and 8; at 3 and 4
// it is disabled; between ticks 5 and 6 the pass and fail actions are turned
// off, and back on between 7 and 8. a_def (line 48) fails at tick 2 and has to
// be reported with an error; a_off (line 49) fails only at tick 7, while fail
// actions are off, and must not be reported. a_null has a null pass
// statement. a_warn (line 51) and a_info report with $warning and $info at
// tick 2. The wording of the messages is not compared. Icarus Verilog 13.0
// does not support these assertions. The 5.052 release of Verilator runs the
// action blocks before the NBA region of the tick, so they see n = k - 1.

`timescale 1ns/1ns

module test_concurrent_assert_actions;
  logic clk = 0, go = 0, x = 0, rst = 0, g_def = 0, g_off = 0, g_null = 0, g_sev = 0;
  int n = 0, f_null = 0;
  int p_q[$], f_q[$];

  always #5 clk = ~clk;   // tick k at 10 * k - 5

  always @(posedge clk) n <= n + 1;

  a_pf: assert property (@(posedge clk) disable iff (rst) go |-> x) p_q.push_back(n);
    else f_q.push_back(n);
  a_def: assert property (@(posedge clk) g_def |-> x);
  a_off: assert property (@(posedge clk) g_off |-> x);
  a_null: assert property (@(posedge clk) g_null |-> x) ; else f_null++;
  a_warn: assert property (@(posedge clk) g_sev |-> x) else $warning("a_warn tick %0d", n);
  a_info: assert property (@(posedge clk) g_sev |-> x) else $info("a_info tick %0d", n);

  // Sets the values sampled at the next tick.
  task automatic tick(logic [7:0] v);
    {go, x, rst, g_def, g_off, g_null, g_sev} = v[6:0];
    #10;
  endtask

  function automatic string ticks(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    //      go x rst g_def g_off g_null g_sev
    tick(8'b0_1_1_0_0_0_0_0);   // tick 1
    tick(8'b0_1_0_0_1_0_1_1);   // tick 2
    tick(8'b0_1_0_1_0_0_0_0);   // tick 3
    tick(8'b0_1_1_1_0_0_0_0);   // tick 4
    tick(8'b0_0_0_0_0_0_0_0);   // tick 5
    $assertpassoff;
    $assertfailoff;
    tick(8'b0_1_1_0_0_0_0_0);   // tick 6
    tick(8'b0_1_0_0_0_1_0_0);   // tick 7
    $assertpasson;
    $assertfailon;
    tick(8'b0_1_0_0_0_0_0_0);   // tick 8
    $display("a_pf passes at ticks%s; failures at ticks%s", ticks(p_q), ticks(f_q));
    $display("a_null failures %0d", f_null);
    $finish;
  end
endmodule
