/*
:name: test_illegal_cg_bin_function_output_arg
:description: the with clause of a coverpoint bin calls a function with an output formal argument (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with clause of the bins hi calls copy, whose formal o is an output argument
:expected_stderr_regex: test_illegal_cg_bin_function_output_arg\.sv:44:
*/
// IEEE 1800-2023 §19.5: a function called in a covergroup_expression, which
// the with clause of a bin is (Syntax 19-2), shall have no output, inout or
// ref formal. keep and copy are both automatic and assign nothing but their
// own formals, and the covergroup argument k that they are given is a
// non-ref argument, which a covergroup_expression may use as a variable.
// keep takes k as an input, so the bins lo are legal. copy also has the
// output formal o, which it sets to its input n, so the call copy(k, k)
// hands k back its own value; that call in the with clause of the bins hi is
// the one error. With o removed from copy the design is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that copy has an output, inout or non-const ref argument, the rule of
// 19.5, and accepts the design once o is removed. Icarus Verilog 13.0 does
// not implement covergroups; its syntax errors are no evidence for the rule.

module test_illegal_cg_bin_function_output_arg;
  bit [3:0] v;

  function automatic int keep(input int n);
    return n;
  endfunction

  function automatic int copy(input int n, output int o);
    o = n;
    return n;
  endfunction

  covergroup cg (input int k);
    cp: coverpoint v {
      bins lo[] = {[0:15]} with (item <= keep(k));
      bins hi[] = {[0:15]} with (item > copy(k, k));   // illegal: output formal
    }
  endgroup

  cg g = new(3);

  initial $display("not reached");
endmodule
