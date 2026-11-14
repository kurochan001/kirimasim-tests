/*
:name: test_illegal_cg_constant_of_other_class
:description: a bin value of an embedded covergroup uses a global constant of another class, while a global or instance constant referenced from a covergroup expression shall be a member of the enclosing class (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the value of the bin top uses limits::TOP, a global constant of the class limits, which is not the class holder that encloses the covergroup
:expected_stderr_regex: test_illegal_cg_constant_of_other_class\.sv:43:
*/
// IEEE 1800-2023 §19.5: a covergroup_expression may use as variables only
// constant expressions, global and instance constants (8.19) and non-ref
// arguments of the covergroup, and the global and instance constants it
// references shall be members of the enclosing class. The syntax of 19.5
// uses covergroup_expression for the values of bins.
// holder encloses the covergroup cg. Its bin own uses OWN, a global constant
// of holder, which is allowed. The bin top uses TOP, a global constant of the
// class limits: a constant of a class, but not of the enclosing one, and a
// const class property is not a constant expression (11.2.1). That is the
// only error; without the bin top the design is legal.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading syntax
// errors fall on every line of the construct, including the line that
// :expected_stderr_regex: names. The 5.054 release of Verilator rejects every
// class constant in a bin value, also the allowed OWN on line 42, so its error
// on line 43 does not come from this rule either. Neither is evidence for the
// rule, and the cited clause alone decides this test.

module test_illegal_cg_constant_of_other_class;
  class limits;
    static const int TOP = 3;
  endclass

  class holder;
    static const int OWN = 2;
    int v;
    covergroup cg;
      coverpoint v {
        bins own = {OWN};
        bins top = {limits::TOP};   // illegal: a constant of another class
      }
    endgroup
    function new();
      cg = new;
    endfunction
  endclass

  holder h;

  initial begin
    h = new;
    $display("not reached");
  end
endmodule
