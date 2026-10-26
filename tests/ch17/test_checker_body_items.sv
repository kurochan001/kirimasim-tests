/*
:name: test_checker_body_items
:description: A checker body holds let, sequence, property and function declarations, deferred and concurrent assertions with checker action blocks, a nested checker declaration and instance, a covergroup, checker variable assignments, default clocking and default disable iff, initial, always_comb, always_latch, always_ff and final procedures, and a generate block (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.5 17.3 17.7 17.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_body_items.expected
*/
// IEEE 1800-2023 17.2: a checker body may hold let, sequence, property and
// function declarations; deferred and concurrent assertions; checker
// declarations and instances of other checkers; covergroup declarations and
// instances; checker variable declarations and assignments; default clocking
// and default disable iff; initial, always_comb, always_latch, always_ff and
// final procedures; and generate blocks. Action blocks of the assertions are
// checker action blocks, and the rest is the checker body. The checker below
// holds one of each. The counters show when each element ran: the two
// assertions without their own clock use the default clocking and the default
// disable, the deferred assertion reports when its expression becomes false,
// and the action blocks count the edges that passed and failed. clk rises at
// 5, 15, ..., 45; d is 4'd0, 4'd9, 4'd5, 4'd12 and 4'd15 at those edges, and
// en is 0, 0, 1, 0 and 1.

`timescale 1ns/1ns

checker body_items(input logic clk, input logic en, input logic [3:0] d,
                   output int prob_fail, output int seq_fail, output int def_fail,
                   output int act_pass, output int act_fail,
                   output logic [3:0] comb_q, output logic [3:0] latch_q,
                   output int ff_n, output int gen_n, output int nested_n);
  // Declarations of a let, a sequence, a property and a function.
  let is_five = (d == 4'd5);
  sequence s_five; is_five; endsequence
  property p_low; d < 4'd8; endproperty
  function automatic int inc(int x);
    return x + 1;
  endfunction

  // Checker variable written by a continuous assignment.
  logic [3:0] cur;
  assign cur = d;

  // A checker declaration and an instance of it inside the body.
  checker nested(input logic clk, input logic sig, output int n);
    always_ff @(posedge clk)
      if (sig) n <= n + 1;
  endchecker : nested
  nested u_nested(.clk(clk), .sig(en), .n(nested_n));

  // A covergroup declaration and an instance outside the procedures.
  covergroup cg @(posedge clk);
    cp: coverpoint d;
  endgroup : cg
  cg ci = new;

  // Defaults for the assertions that do not name a clock or a disable.
  default clocking @(posedge clk); endclocking
  default disable iff (d == 4'd15);

  // Concurrent assertion using the default clocking and the default disable.
  a_prop: assert property (p_low) else prob_fail = prob_fail + 1;
  // Concurrent assertion using the sequence and the let.
  a_seq: assert property (@(posedge clk) s_five |-> d[0] == 1'b0)
    else seq_fail = seq_fail + 1;
  // Deferred assertion, reported when its expression changes to false.
  a_def: assert #0 (d != 4'd9) else def_fail = def_fail + 1;

  initial begin
    @(posedge clk);
    a_init: assert (en) else $display("initial: en=0 at %0d", $time);
  end

  always_comb comb_q = d ^ {3'b000, en};
  always_latch if (en) latch_q = d;
  always_ff @(posedge clk) ff_n <= inc(ff_n) + cur;

  generate
    if (1) begin : g
      always_ff @(posedge clk) gen_n <= gen_n + 1;
    end
  endgenerate

  // Action blocks of an assertion are checker action blocks.
  a_act: assert property (@(posedge clk) en)
    act_pass = act_pass + 1;
    else act_fail = act_fail + 1;

  final begin
    $display("comb=%0d latch=%0d ff=%0d gen=%0d nested=%0d",
             comb_q, latch_q, ff_n, gen_n, nested_n);
    $display("def=%0d seq=%0d prop=%0d pass=%0d fail=%0d",
             def_fail, seq_fail, prob_fail, act_pass, act_fail);
  end
endchecker : body_items

module test_checker_body_items;
  logic clk = 1'b0, en = 1'b0;
  logic [3:0] d = 4'd0;
  int prob_fail, seq_fail, def_fail, act_pass, act_fail;
  int ff_n, gen_n, nested_n;
  logic [3:0] comb_q, latch_q;

  always #5 clk = ~clk;

  body_items u(.clk(clk), .en(en), .d(d), .prob_fail(prob_fail),
               .seq_fail(seq_fail), .def_fail(def_fail),
               .act_pass(act_pass), .act_fail(act_fail),
               .comb_q(comb_q), .latch_q(latch_q),
               .ff_n(ff_n), .gen_n(gen_n), .nested_n(nested_n));

  initial begin
    #10 d = 4'd9;
    #10 d = 4'd5;
    #2 en = 1'b1;
    #6 d = 4'd12;
    #2 en = 1'b0;
    #8 d = 4'd15;
    #2 en = 1'b1;
    #10 $finish;
  end
endmodule
