/*
:name: test_procedural_assertion_clock_inference
:description: a procedural concurrent assertion without a clock takes the clock of its procedure when the procedure has no other timing control, one event control and exactly one event expression that is an event variable, a clocking block or a whole edge expression with iff whose terms the body does not use; otherwise it takes the default clocking (IEEE 1800-2023 Section 16.14.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.6 16.16 14.12 14.13 9.4.2 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_procedural_assertion_clock_inference.expected
*/
// IEEE 1800-2023 §16.14.6: an assertion in a procedure without a clocking
// event takes the clock inferred from the procedure; if none can be inferred,
// it takes the default clocking (§14.12), which an inferred clock overrides
// (§16.16). A clock is inferred when the procedure has no blocking timing
// control, exactly one event control, and exactly one event expression in it
// that is a sole event variable, a sole clocking block name, or a whole edge
// expression (with its iff) and not part of one, and whose event variable,
// clocking block or terms of the edge operand appear elsewhere in the body
// only in clocking events, assertions or, for a clocking block, references
// to its signals. Here clk ticks at 5, 15, ... and the default clocking dclk
// at 8, 18, ...; each assertion is t |-> 1'b0 on its own t, high around one
// time only, and its fail action (§16.14.1) records when it fails, which
// shows the clock it uses. a1 in always @(posedge clk) fails at the tick 55;
// clk also appears in the assertion a1x next to it, which is allowed.
// a3 (a #1 in the procedure), a4 (a second event control), a5 (clk used in
// the body), a8 (two event expressions qualify) and a10 (the event ev10 used
// in the body) fall back to dclk and fail at 28, 38, 48, 108 and 118. a2
// infers posedge clk iff en, not posedge clk, nor posedge rst, as rst is used
// in its body: the instance queued at the rst edge at 62 waits for the tick
// at 75, where en is high, and the run of the procedure at 75 queues one
// more. a6 (the event ev, §9.4.2, also the clock of the assertion a6x next
// to it) fails when ev is triggered at 84, and a7 (the clocking block cb7,
// §14.13, whose signal the body reads) at 95.
// Icarus Verilog 13.0 does not support these assertions, and the 5.052
// release of Verilator does not support these procedural assertions.

`timescale 1ns/1ns

module test_procedural_assertion_clock_inference;
  logic clk = 0, dclk = 0, clk_b = 0, en = 0, rst = 0;
  logic t1 = 0, t2 = 0, t3 = 0, t4 = 0, t5 = 0, t6 = 0, t7 = 0, t8 = 0, t10 = 0;
  logic seen2, seen5, v7;
  bit seen10;
  event ev, ev10;
  int f1[$], f2[$], f3[$], f4[$], f5[$], f6[$], f7[$], f8[$], f10[$];

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  initial begin
    #8;
    forever begin
      dclk = ~dclk;   // rising at 8, 18, 28, ...
      #5;
    end
  end

  default clocking dcb @(posedge dclk); endclocking

  clocking cb7 @(posedge clk);
    input t7;
  endclocking

  always @(posedge clk) begin
    a1: assert property (t1 |-> 1'b0) else f1.push_back($time);
    a1x: assert property (@(posedge clk) clk || !clk);
  end

  always @(posedge clk iff en or posedge rst) begin
    seen2 = rst;
    a2: assert property (t2 |-> 1'b0) else f2.push_back($time);
  end

  always @(posedge clk) begin
    #1;
    a3: assert property (t3 |-> 1'b0) else f3.push_back($time);
  end

  always @(posedge clk) begin
    @(negedge clk);
    a4: assert property (t4 |-> 1'b0) else f4.push_back($time);
  end

  always @(posedge clk) begin
    seen5 = clk;
    a5: assert property (t5 |-> 1'b0) else f5.push_back($time);
  end

  always @(ev) begin
    a6: assert property (t6 |-> 1'b0) else f6.push_back($time);
    a6x: assert property (@(ev) 1'b1);
  end

  always @(cb7) begin
    v7 = cb7.t7;
    a7: assert property (t7 |-> 1'b0) else f7.push_back($time);
  end

  always @(posedge clk or posedge clk_b) begin
    a8: assert property (t8 |-> 1'b0) else f8.push_back($time);
  end

  always @(ev10) begin
    seen10 = ev10.triggered;
    a10: assert property (t10 |-> 1'b0) else f10.push_back($time);
  end

  // Raises s from time t0 to t1.
  task automatic window(ref logic s, input int t0, t1);
    #(t0 - $time) s = 1;
    #(t1 - t0) s = 0;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    window(t3, 26, 29);
    window(t4, 36, 39);
    window(t5, 46, 49);
    window(t1, 52, 56);
    fork
      window(t2, 61, 76);
      window(rst, 62, 63);
      window(en, 70, 80);
    join
    #2 t6 = 1;   // 82
    #2 ->ev;
    #2 t6 = 0;
    window(t7, 92, 96);
    window(t8, 102, 109);
    #3 t10 = 1;   // 112
    #2 ->ev10;
    #5 t10 = 0;
    #11;
    $display("a1 (posedge clk) failures at%s", times(f1));
    $display("a2 (posedge clk iff en) failures at%s", times(f2));
    $display("a3 (delay in the procedure) failures at%s", times(f3));
    $display("a4 (second event control) failures at%s", times(f4));
    $display("a5 (clk used in the body) failures at%s", times(f5));
    $display("a6 (event variable) failures at%s", times(f6));
    $display("a7 (clocking block) failures at%s", times(f7));
    $display("a8 (two qualifying expressions) failures at%s", times(f8));
    $display("a10 (event variable used in the body) failures at%s", times(f10));
    $finish;
  end
endmodule
