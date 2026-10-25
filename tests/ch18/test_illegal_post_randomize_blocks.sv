/*
:name: test_illegal_post_randomize_blocks
:description: a post_randomize() override that waits on an event is an error, since the method is a function (IEEE 1800-2023 Section 18.6.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.6.3 13.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the post_randomize() of pob_obj contains an event control, but post_randomize() is a function and cannot block
:expected_stderr_regex: test_illegal_post_randomize_blocks\.sv:30:
*/
// IEEE 1800-2023 §18.6.3: the built-in methods pre_randomize() and
// post_randomize() are functions and cannot block; a function cannot hold a
// time-controlling statement (§13.4). The post_randomize() of pob_obj
// triggers an event, which does not block and is legal, and then waits for
// the event done, which is the error. test_illegal_pre_randomize_blocks has
// a pre_randomize() that waits on a delay.
// The class is not randomized here: the rule is broken by the declaration
// alone. Icarus Verilog 13.0 does not support events as class members, so
// its error on the line of their declaration does not count.

class pob_obj;
  rand bit [3:0] v;
  event seen, done;

  function void post_randomize();
    -> seen;
    @(done);   // illegal: post_randomize() cannot block
  endfunction
endclass

module test_illegal_post_randomize_blocks;
  pob_obj o = new;
  initial $display("v=%0d", o.v);
endmodule
