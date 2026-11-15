/*
:name: test_illegal_cg_cross_bin_function_output_arg
:description: a cross bin calls a function with an output formal argument in its intersect list (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the intersect list of the cross bin bad calls copy, whose formal o is an output argument
:expected_stderr_regex: test_illegal_cg_cross_bin_function_output_arg\.sv:48:
*/
// IEEE 1800-2023 §19.6: identifiers and function calls in a cross obey the
// same restrictions as in a coverpoint (19.5), so a function called in a
// covergroup_expression of a cross, such as a value in the intersect list of
// a cross bin (Syntax 19-4), shall have no output, inout or ref formal. keep
// and copy are both automatic and assign nothing but their own formals, and
// the covergroup argument k that they are given is a non-ref argument,
// which a covergroup_expression may use as a variable. The bin ok calls
// keep, which takes k as an input, and is legal. copy also has the output
// formal o, which it sets to its input n, so the call copy(k, k) hands k
// back its own value; that call in the bin bad is the one error. With o
// removed from copy the design is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that copy has an output, inout or non-const ref argument, and accepts the
// design once o is removed. Icarus Verilog 13.0 does not implement
// covergroups; its syntax errors are no evidence for the rule.

module test_illegal_cg_cross_bin_function_output_arg;
  bit [1:0] a, b;

  function automatic int keep(input int n);
    return n;
  endfunction

  function automatic int copy(input int n, output int o);
    o = n;
    return n;
  endfunction

  covergroup cg (input int k);
    ca: coverpoint a;
    cb: coverpoint b;
    x: cross ca, cb {
      bins ok = binsof(ca) intersect {keep(k)};
      bins bad = binsof(cb) intersect {copy(k, k)};   // illegal: output formal
    }
  endgroup

  cg g = new(1);

  initial $display("not reached");
endmodule
