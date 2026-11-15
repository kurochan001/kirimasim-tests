/*
:name: test_illegal_ref_formal_nonblocking_target
:description: A ref formal without static may refer to an automatic variable, so it cannot be the target of a nonblocking assignment (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the task put writes its ref formal r, declared without static, with a nonblocking assignment
:expected_stderr_regex: test_illegal_ref_formal_nonblocking_target\.sv:35:
*/
// IEEE 1800-2023 §13.5.2: a variable passed by reference may be automatic, so
// a ref formal shall not be used in a context forbidden for automatic
// variables unless it is ref static. §6.21: automatic variables shall not be
// written with nonblocking assignments.
//
// put writes the module variable w with a nonblocking assignment, which is
// legal, and its ref formal r, declared without static, which is the error,
// although the caller passes the static module variable v: the rule is about
// the formal, not about the actual of one call. Without that assignment the
// design is legal and prints "0 1".
// Icarus Verilog 13.0 does not support ref ports: it reports that at the
// task header, also for the legal design, and then reports the write of r
// as one of an automatic variable, so its error does not count. The 5.054
// release of Verilator accepts the design.

module test_illegal_ref_formal_nonblocking_target;
  int v;
  int w;

  task automatic put(ref int r, input int k);
    w <= k;
    r <= k;   // illegal: a ref formal without static
  endtask

  initial begin
    put(v, 1);
    #1 $display("%0d %0d", v, w);
  end
endmodule
