/*
:name: test_illegal_pre_randomize_blocks
:description: a pre_randomize() override that waits on a delay is an error, since the method is a function (IEEE 1800-2023 Section 18.6.3)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.6.3 13.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pre_randomize() of prb_obj contains a delay control, but pre_randomize() is a function and cannot block
:expected_stderr_regex: test_illegal_pre_randomize_blocks\.sv:29:
*/
// IEEE 1800-2023 §18.6.3: the built-in methods pre_randomize() and
// post_randomize() are functions and cannot block; a function cannot hold a
// time-controlling statement (§13.4). The pre_randomize() of prb_obj counts
// its calls, which is legal, and then waits one time unit, which is the
// error. test_illegal_post_randomize_blocks has a post_randomize() that
// waits on an event.
// The class is not randomized here: the rule is broken by the declaration
// alone.

class prb_obj;
  rand bit [3:0] v;
  int pre_calls;

  function void pre_randomize();
    pre_calls++;
    #1;   // illegal: pre_randomize() cannot block
  endfunction
endclass

module test_illegal_pre_randomize_blocks;
  prb_obj o = new;
  initial $display("calls=%0d", o.pre_calls);
endmodule
