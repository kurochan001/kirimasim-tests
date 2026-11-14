/*
:name: test_illegal_cg_constant_set_after_new
:description: the class constructor assigns the instance constant that a bin value of the embedded covergroup uses only after it constructs the covergroup, while the initializer shall come before the covergroup constructor call (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin k uses the instance constant K, and the constructor of holder assigns K after the call cg = new instead of before it
:expected_stderr_regex: test_illegal_cg_constant_set_after_new\.sv:(40|41):
*/
// IEEE 1800-2023 §19.5: the initializers of the instance constants that a
// covergroup_expression references shall appear in the class constructor
// before the call of the covergroup constructor that refers to them. K is an
// instance constant of holder (8.19: a const property without an initial
// value, assigned once in the constructor), and the value of the bin k uses
// it. The constructor calls cg = new first and assigns K afterwards, which is
// the one error: with the two statements swapped the design is legal. A tool
// can report the assignment or the constructor call.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading syntax
// errors fall on every line of the construct, including the lines that
// :expected_stderr_regex: names, so they are no evidence for the rule there.
// The 5.054 release of Verilator rejects every class constant in a bin value,
// so it reports the allowed use of K on line 36 instead. The cited clause alone
// decides this test.

module test_illegal_cg_constant_set_after_new;
  class holder;
    const int K;
    int v;
    covergroup cg;
      coverpoint v {
        bins k = {K};
      }
    endgroup
    function new();
      cg = new;
      K = 3;   // illegal: after the covergroup constructor call
    endfunction
  endclass

  holder h;

  initial begin
    h = new;
    $display("not reached");
  end
endmodule
