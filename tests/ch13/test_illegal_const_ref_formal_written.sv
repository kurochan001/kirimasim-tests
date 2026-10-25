/*
:name: test_illegal_const_ref_formal_written
:description: A subroutine cannot assign to a formal declared const ref (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a task assigns to its const ref formal
:expected_stderr_regex: test_illegal_const_ref_formal_written\.sv:26:
*/
// IEEE 1800-2023 §13.5.2: a const ref formal is passed by reference but is
// read-only; an attempt of the subroutine to alter it shall be a compile
// error. The task reads its const ref formal, which is legal, and then
// assigns to it.
// Icarus Verilog 13.0 rejects the design earlier, with a syntax error at
// const ref (not supported), which does not count.

module test_illegal_const_ref_formal_written;
  int total;

  task automatic add_twice(const ref int v);
    total = total + v;
    v = 0;   // illegal: writes a const ref formal
  endtask

  initial begin
    int x = 3;
    total = 0;
    add_twice(x);
    $display("%0d", total);
  end
endmodule
