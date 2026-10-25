/*
:name: test_named_blocks_scope_items_and_disable
:description: a named begin block and a named fork block each create a scope whose variable, local parameter and named event are reached through the block name from another process, and the named fork block can be disabled by name (IEEE 1800-2023 Section 9.3.4)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.3.4 9.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_named_blocks_scope_items_and_disable.expected
*/
// IEEE 1800-2023 §9.3.4: naming a begin or fork block with ": name" creates a
// new hierarchy scope, so the variables, parameters and named events
// declared in it can be referenced hierarchically with the block name, and
// the block can be named in a disable statement (9.6.2).
//
// nb (begin) declares v, the local parameter LP and the event ev, and waits
// for ev. fb (fork) declares w and LW; its branches set w to 3 at time 1
// and would set it to 9 at time 20. Another process reads nb.v, nb.LP,
// fb.w and fb.LW, triggers nb.ev, and at time 4 disables fb, which lets the
// join finish at once: w stays 3.

module test_named_blocks_scope_items_and_disable;
  int fb_over = -1, fb_w = -1;

  initial begin : nb
    int v;
    localparam int LP = 7;
    event ev;
    v = 5;
    @(ev) v = 6;
  end

  initial begin
    fork : fb
      int w;
      localparam int LW = 11;
      #1 w = 3;
      #20 w = 9;
    join
    fb_over = $time;
    fb_w = fb.w;
  end

  initial begin
    #2 $display("nb.v=%0d nb.LP=%0d fb.w=%0d fb.LW=%0d", nb.v, nb.LP, fb.w, fb.LW);
    -> nb.ev;
    #1 $display("after nb.ev: nb.v=%0d", nb.v);
    #1 disable fb;
    #1 $display("fb disabled: join over at t=%0d, w=%0d", fb_over, fb_w);
  end
endmodule
