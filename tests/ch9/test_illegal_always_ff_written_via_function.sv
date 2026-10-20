/*
:name: test_illegal_always_ff_written_via_function
:description: A variable assigned by a function that an always_ff procedure calls cannot be written by another process (IEEE 1800-2023 Section 9.2.2.4)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: q is assigned by a function that the always_ff procedure calls, and by an initial procedure
:expected_stderr_regex: test_illegal_always_ff_written_via_function\.sv:(23|25|26):
*/
// IEEE 1800-2023 §9.2.2.4: the variables an always_ff procedure assigns include
// those assigned by the functions it calls, and no other process can write
// them. set_q assigns q and is called from always_ff, and the initial procedure
// writes q as well; a tool can report any of the three places.

module test_illegal_always_ff_written_via_function;
  logic clk = 0;
  int q;
  function void set_q(int v);
    q = v;                           // illegal: q is assigned for always_ff
  endfunction
  always_ff @(posedge clk) set_q(1); // illegal: through this call
  initial q = 2;                     // illegal: and by another process
endmodule
