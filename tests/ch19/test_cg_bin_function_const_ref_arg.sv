/*
:name: test_cg_bin_function_const_ref_arg
:description: A function whose only ref formal is const ref can be called in a bin range of a coverpoint, and the bin bounds are the values it returns for each instance (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bin_function_const_ref_arg.expected
*/
// IEEE 1800-2023 §19.5: a function may be called in a covergroup_expression,
// such as a bound of a bin range, when it is automatic, has no side effects,
// reads no variable outside its own scope and has no output, inout or ref
// formal; a const ref formal is allowed. A non-ref argument of the covergroup
// may be used as a variable there.
// twice reads its const ref formal n and returns 2 * n. The bins of cp are
// lo = [0 : twice(k) - 1] and hi = [twice(k) : 15], so the instance g3, made
// with k = 3, has lo = 0..5 and hi = 6..15, and g5, with k = 5, has
// lo = 0..9 and hi = 10..15. get_inst_coverage(c, t) on the coverpoint gives
// the covered bins and the bins of one instance (19.8). Sampling 5, 6 and 10
// covers lo, then hi of g3, while g5 covers hi only with 10; bounds that did
// not follow the returned value would move the line where each hi is hit.
// Icarus Verilog 13.0 does not compile covergroups or const ref, and the
// 5.054 release of Verilator accepts only constant bin bounds and does not
// support the arguments of get_inst_coverage on a coverpoint.

module test_cg_bin_function_const_ref_arg;
  bit [3:0] v;

  function automatic int twice(const ref int n);
    return 2 * n;
  endfunction

  covergroup cg (input int k);
    cp: coverpoint v {
      bins lo = {[0:twice(k) - 1]};
      bins hi = {[twice(k):15]};
    }
  endgroup

  cg g3 = new(3);
  cg g5 = new(5);

  task automatic put(bit [3:0] x);
    int c3, t3, c5, t5;
    v = x;
    g3.sample();
    g5.sample();
    void'(g3.cp.get_inst_coverage(c3, t3));
    void'(g5.cp.get_inst_coverage(c5, t5));
    $display("v=%0d: g3 %0d/%0d, g5 %0d/%0d", x, c3, t3, c5, t5);
  endtask

  initial begin
    put(5);
    put(6);
    put(10);
  end
endmodule
