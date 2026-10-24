/*
:name: test_illegal_constant_function_in_generate_block
:description: a function declared inside a generate block cannot be a constant function (IEEE 1800-2023 Section 13.4.3)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f is declared in a generate block and called in the initial value of the localparam P
:expected_stderr_regex: test_illegal_constant_function_in_generate_block\.sv:30:
*/
// IEEE 1800-2023 §13.4.3: a constant function shall not be declared inside a
// generate block (Clause 27). f is declared in the conditional generate block
// gb and called in the initial value of the localparam P of that block, with a
// constant argument; f itself meets every other constraint. The same function
// declared in the module, g, may be called in the initial value of Q.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_constant_function_in_generate_block;
  function int g(input int a);
    return a * 2;
  endfunction
  localparam int Q = g(3);
  if (1) begin : gb
    function int f(input int a);
      return a * 2;
    endfunction
    localparam int P = f(3);   // illegal
  end
  initial $display("%0d %0d", gb.P, Q);
endmodule
