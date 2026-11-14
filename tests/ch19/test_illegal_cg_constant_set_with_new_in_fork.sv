/*
:name: test_illegal_cg_constant_set_with_new_in_fork
:description: the class constructor assigns the instance constant that a bin value of the embedded covergroup uses, and then constructs the covergroup, both in the body of one fork-join_none, while such an initializer shall not appear with the covergroup constructor call in the body of a fork-join_none (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor of holder assigns the instance constant K, which the bin k uses, and calls cg = new in the body of the same fork-join_none
:expected_stderr_regex: test_illegal_cg_constant_set_with_new_in_fork\.sv:(44|45):
*/
// IEEE 1800-2023 §19.5: the initializer of an instance constant that a
// covergroup_expression references shall not appear together with the
// covergroup constructor call in the body of a fork-join_none, before or
// after the call. Here K = 3 comes before cg = new in one begin-end block,
// the only process that the fork-join_none of the constructor starts. A
// function may contain fork-join_none (13.4.4), the statements are in the
// constructor, where K is assigned once (8.19) and the covergroup variable
// is assigned in the new method of its class (19.4); the placement in the
// fork-join_none is the one error, and without the fork-join_none the design
// is legal. A tool can report the assignment or the constructor call.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading syntax
// errors fall on every line of the construct, including the lines that
// :expected_stderr_regex: names, so they are no evidence for the rule there.
// The 5.054 release of Verilator rejects every class constant in a bin value,
// so it reports the allowed use of K on line 38 instead. The cited clause alone
// decides this test.

module test_illegal_cg_constant_set_with_new_in_fork;
  class holder;
    const int K;
    int v;
    covergroup cg;
      coverpoint v {
        bins k = {K};
      }
    endgroup
    function new();
      fork
        begin
          K = 3;
          cg = new;   // illegal: in one fork-join_none with the initializer of K
        end
      join_none
    endfunction
  endclass

  holder h;

  initial begin
    h = new;
    #1 $display("not reached");
  end
endmodule
