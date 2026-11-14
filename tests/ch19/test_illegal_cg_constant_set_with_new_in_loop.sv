/*
:name: test_illegal_cg_constant_set_with_new_in_loop
:description: the class constructor assigns the instance constant that a bin value of the embedded covergroup uses, and then constructs the covergroup, both in the body of one repeat loop, while such an initializer shall not appear with the covergroup constructor call in the body of a loop (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor of holder assigns the instance constant K, which the bin k uses, and calls cg = new in the body of the same repeat loop
:expected_stderr_regex: test_illegal_cg_constant_set_with_new_in_loop\.sv:(43|44):
*/
// IEEE 1800-2023 §19.5: the initializer of an instance constant that a
// covergroup_expression references shall not appear together with the
// covergroup constructor call in the body of a looping statement (12.7),
// before or after the call. Here K = 3 comes before cg = new, as §19.5 also
// requires, but both are in the body of repeat (1). The loop runs once, so K
// is assigned once in the constructor, as 8.19 requires for an instance
// constant, and the covergroup is constructed in the new method of its class
// (19.4); the placement in the loop is the one error, and without the loop
// the design is legal. A tool can report the assignment or the constructor
// call.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading syntax
// errors fall on every line of the construct, including the lines that
// :expected_stderr_regex: names, so they are no evidence for the rule there.
// The 5.054 release of Verilator rejects every class constant in a bin value,
// so it reports the allowed use of K on line 38 instead. The cited clause alone
// decides this test.

module test_illegal_cg_constant_set_with_new_in_loop;
  class holder;
    const int K;
    int v;
    covergroup cg;
      coverpoint v {
        bins k = {K};
      }
    endgroup
    function new();
      repeat (1) begin
        K = 3;
        cg = new;   // illegal: in one loop body with the initializer of K
      end
    endfunction
  endclass

  holder h;

  initial begin
    h = new;
    $display("not reached");
  end
endmodule
