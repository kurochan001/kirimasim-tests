/*
:name: test_procedural_assertion_disable_label
:description: disabling a procedural concurrent assertion by its label clears only its own pending instances, disabling a scope that is not the outermost one of the procedure clears none, and an attempt that has matured goes on when its procedure is disabled (IEEE 1800-2023 Section 16.14.6.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6.4 16.14.6 9.6.2 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_disable_label.expected
*/
// IEEE 1800-2023 §16.14.6.4: a disable statement that names a procedural
// concurrent assertion clears its pending instances and leaves those of the
// other assertions; disabling a task or a scope that is not the outermost
// one of the procedure clears nothing; and once an instance has matured, no
// disable affects its evaluation attempt. An instance matures in the
// Observed region and is evaluated at the next tick of its clock
// (§16.14.6). The procedures run when go rises at 42 and falls at 52: at 42
// p_dis disables a_x after queueing both a_x and a_y, at 52 it does not;
// a_in is queued in an inner block that is then disabled (§9.6.2). All of
// these fail at the tick after they are queued. a_long, queued when go2
// rises at 62, starts at 65 and fails two ticks later, at 85, although
// p_long, the outermost block of its procedure, is disabled at 72 while it
// waits in its delay. The fail actions (§16.14.1) record the times.

`timescale 1ns/1ns

module test_procedural_assertion_disable_label;
  logic clk = 0, go = 0, go2 = 0;
  int f_x[$], f_y[$], f_in[$], f_long[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  always @(go) begin : p_dis
    a_x: assert property (@(posedge clk) 1'b0) else f_x.push_back($time);
    a_y: assert property (@(posedge clk) 1'b0) else f_y.push_back($time);
    if (go) disable a_x;
  end

  always @(go) begin : p_inner
    begin : inner
      a_in: assert property (@(posedge clk) 1'b0) else f_in.push_back($time);
      disable inner;
    end
  end

  always @(go2) begin : p_long
    a_long: assert property (@(posedge clk) 1'b1 ##2 1'b0) else f_long.push_back($time);
    #30;
  end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #42 go = 1;
    #10 go = 0;
    #10 go2 = 1;
    #10 disable p_long;
    #28;
    $display("a_x failures:%s", times(f_x));
    $display("a_y failures:%s", times(f_y));
    $display("a_in failures:%s", times(f_in));
    $display("a_long failures:%s", times(f_long));
    $finish;
  end
endmodule
