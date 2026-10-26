/*
:name: test_illegal_covergroup_output_formal
:description: An output or inout is illegal as a formal argument of a covergroup, while an input and a ref argument treated as const ref are allowed (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the covergroup bad declares the output formal argument o
:expected_stderr_regex: test_illegal_covergroup_output_formal\.sv:28:
*/
// IEEE 1800-2023 §19.3: an output or inout shall be illegal as a formal
// argument of a covergroup. A covergroup cannot modify any argument to new,
// so a ref argument is treated like a read-only const ref. The covergroup ok
// takes an input and a ref formal and is legal. The covergroup bad takes an
// output formal and is illegal.

module test_illegal_covergroup_output_formal;
  int x = 0;
  int r = 0;

  covergroup ok(input int i, ref int rv);
    coverpoint x;
  endgroup

  covergroup bad(output int o);   // illegal: output formal
    coverpoint x;
  endgroup

  ok g;

  initial begin
    g = new(x, r);
    g.sample();
    $display("ok");
  end
endmodule
