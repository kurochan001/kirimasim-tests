/*
:name: test_concurrent_assertion_names_and_control
:description: a named concurrent assertion can be turned off and on through its hierarchical name with the assertion control tasks while its neighbor keeps running, an unnamed assertion creates no scope and its failure is still reported, and a property that no assertion statement uses is never evaluated (IEEE 1800-2023 Section 16.14)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14 20.11 20.10 16.11 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concurrent_assertion_names_and_control.expected
:expected_stderr_regex: (?i)\A(?=[\s\S]*error[^\n]*test_concurrent_assertion_names_and_control\.sv:56:)
*/
// IEEE 1800-2023 §16.14: a property on its own is never evaluated for
// checking; only an assertion statement makes it so. A concurrent assertion
// can be referenced by its optional name, also hierarchically; the execution
// of assertions can be controlled with the tasks of §20.11; when an assertion
// has no name, the tool gives it one for reporting, and it creates no scope.
// p_unused and p_used have the same form, a sequence whose match item
// (§16.11) calls a counting function when s_trig is high, followed by |->
// 1'b1, but only p_used is asserted; s_trig is high at two ticks, so only
// the function of p_used is called, twice. The unnamed assertion in g_u fails
// at 5, and %m in its fail action names g_u, as the assertion has no scope of
// its own. $assertoff(0, ...g_n.a_deep) between 15 and 25 and $asserton
// between 25 and 35 switch off only a_deep: it fails at 15 and 45 but not at
// 25, while a_other in the same block fails at 35. The unnamed assertion
// without else at line 56 fails at 55 and has to be reported with an error
// (§20.10); the wording of the message is not compared. Icarus Verilog 13.0
// does not support these assertions. The 5.052 release of Verilator gives
// the other lines but never calls the function of the match item.

`timescale 1ns/1ns

module test_concurrent_assertion_names_and_control;
  logic clk = 0, s_trig = 0, t1 = 0, t2 = 0, t3 = 0, t4 = 0;
  int calls_unused = 0, calls_used = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  function automatic void bump_unused(); calls_unused++; endfunction
  function automatic void bump_used(); calls_used++; endfunction

  property p_unused; @(posedge clk) (s_trig, bump_unused()) |-> 1'b1; endproperty
  property p_used; @(posedge clk) (s_trig, bump_used()) |-> 1'b1; endproperty
  a_used: assert property (p_used);

  if (1) begin : g_u
    assert property (@(posedge clk) t1 |-> 1'b0) else $display("%0d: fail action in %m", $time);
  end

  if (1) begin : g_n
    a_deep: assert property (@(posedge clk) t2 |-> 1'b0) else $display("%0d: a_deep", $time);
    a_other: assert property (@(posedge clk) t3 |-> 1'b0) else $display("%0d: a_other", $time);
  end

  assert property (@(posedge clk) t4 |-> 1'b0);

  initial begin
    t1 = 1;                                          // 5
    #10 t1 = 0; t2 = 1; s_trig = 1;                  // 15
    #10 t2 = 1; s_trig = 0;                          // 25
    $assertoff(0, test_concurrent_assertion_names_and_control.g_n.a_deep);
    #10 t2 = 0; t3 = 1; s_trig = 1;                  // 35
    $asserton(0, test_concurrent_assertion_names_and_control.g_n.a_deep);
    #10 t3 = 0; t2 = 1; s_trig = 0;                  // 45
    #10 t2 = 0; t4 = 1;                              // 55
    #10 t4 = 0;
    #10 $display("calls through the asserted property %0d, through the unused one %0d",
                 calls_used, calls_unused);
    $finish;
  end
endmodule
