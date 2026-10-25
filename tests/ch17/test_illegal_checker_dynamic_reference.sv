/*
:name: test_illegal_checker_dynamic_reference
:description: A checker cannot read an element of a queue declared in the scope that encloses the checker declaration (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker reads element 0 of the queue q of the enclosing compilation-unit scope
:expected_stderr_regex: test_illegal_checker_dynamic_reference\.sv:29:
*/
// IEEE 1800-2023 17.2: a checker shall not reference the elements of the
// dynamic variables of the scope of its declaration. The queue q has the
// compilation-unit scope and is such a variable, and its element q[0] is read
// in the always_ff procedure of the checker. The rest of the design is legal:
// the module pushes one element and raises the clock once.
// Icarus Verilog 13.0 does not support checkers at all. Verilator 5.052
// supports the unit-level checker but accepts the reference, so neither
// release produces the expected result.

`timescale 1ns/1ns

int q[$];
logic clk = 1'b0;

checker dyn_ref(logic clk, output int n);
  always_ff @(posedge clk) n <= n + q[0];   // illegal
endchecker : dyn_ref

module test_illegal_checker_dynamic_reference;
  int seen;

  dyn_ref u(.clk(clk), .n(seen));

  initial begin
    q.push_back(3);
    #1 clk = 1'b1;
  end
endmodule
