/*
:name: test_pre_post_randomize
:description: pre_randomize and post_randomize run before and after randomize for an object and its rand object members (IEEE 1800-2023 Section 18.6.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.6.2 18.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pre_post_randomize.expected
*/
// IEEE 1800-2023 §18.6.2: obj.randomize() calls pre_randomize() of obj and of
// its rand object members (18.4) before solving, and post_randomize() of all of
// them after the new values are assigned, so pre_randomize() sees the old
// values and post_randomize() the new ones.

class ppr_child;
  rand bit [3:0] v;
  int pre_calls, post_calls;
  constraint c { v == 4'd3; }
  function void pre_randomize();
    pre_calls++;
  endfunction
  function void post_randomize();
    post_calls++;
  endfunction
endclass

class ppr_parent;
  rand bit [3:0] p;
  rand ppr_child ch;
  int pre_calls, post_calls;
  bit [3:0] p_seen_in_pre, p_seen_in_post;
  constraint c { p == 4'd5; }
  function new();
    ch = new;
  endfunction
  function void pre_randomize();
    pre_calls++;
    p_seen_in_pre = p;
  endfunction
  function void post_randomize();
    post_calls++;
    p_seen_in_post = p;
  endfunction
endclass

module test_pre_post_randomize;
  ppr_parent o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d p=%0d ch.v=%0d", ok, o.p, o.ch.v);
    $display("parent pre=%0d post=%0d, p in pre=%0d in post=%0d",
             o.pre_calls, o.post_calls, o.p_seen_in_pre, o.p_seen_in_post);
    $display("child pre=%0d post=%0d", o.ch.pre_calls, o.ch.post_calls);
  end
endmodule
