/*
:name: test_illegal_cg_bin_function_ref_arg
:description: the with clause of a coverpoint bin calls a function with a ref formal argument that is not const (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with clause of the bins hi calls peek, whose formal n is a ref argument without const
:expected_stderr_regex: test_illegal_cg_bin_function_ref_arg\.sv:44:
*/
// IEEE 1800-2023 §19.5: a function called in a covergroup_expression, which
// the with clause of a bin is (Syntax 19-2), shall have no output, inout or
// ref formal; only const ref is allowed. look and peek are both automatic,
// only read their formal and change nothing, and the covergroup argument k
// that they are given is a non-ref argument, which a covergroup_expression
// may use as a variable. look declares its formal const ref, so the bins lo
// are legal; peek declares the same formal as ref, so its call in the with
// clause of the bins hi is the one error. With const added to peek the
// design is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that peek has an output, inout or non-const ref argument, the rule of
// 19.5, and accepts the design once peek is const ref. Icarus Verilog 13.0
// does not implement covergroups; its syntax error is no evidence for the
// rule.

module test_illegal_cg_bin_function_ref_arg;
  bit [3:0] v;

  function automatic int look(const ref int n);
    return n;
  endfunction

  function automatic int peek(ref int n);
    return n;
  endfunction

  covergroup cg (input int k);
    cp: coverpoint v {
      bins lo[] = {[0:15]} with (item <= look(k));
      bins hi[] = {[0:15]} with (item > peek(k));   // illegal: non-const ref formal
    }
  endgroup

  cg g = new(3);

  initial $display("not reached");
endmodule
