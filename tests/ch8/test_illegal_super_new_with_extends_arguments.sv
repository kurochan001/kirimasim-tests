/*
:name: test_illegal_super_new_with_extends_arguments
:description: when the extends clause gives the arguments of the base constructor, the subclass constructor must not call super.new itself (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor of bad_c calls super.new although its extends clause already gives the base constructor arguments
:expected_stderr_regex: test_illegal_super_new_with_extends_arguments\.sv:44:
*/
// IEEE 1800-2023 §8.17: the arguments of the base constructor can be given in
// the extends clause; then the subclass constructor shall not contain a
// super.new call, and the compiler inserts it. good_c gives the argument in
// its extends clause and has a constructor without super.new; also_c calls
// super.new itself and has no arguments in its extends clause. Both are
// legal; bad_c does both.
// Icarus Verilog 13.0 accepts the design.

class base_c;
  int x;
  function new(int x = 1);
    this.x = x;
  endfunction
endclass

class good_c extends base_c(5);
  int y;
  function new();
    y = 2;
  endfunction
endclass

class also_c extends base_c;
  function new();
    super.new(6);
  endfunction
endclass

class bad_c extends base_c(5);
  function new();
    super.new(3);   // illegal: super.new with arguments in the extends clause
  endfunction
endclass

module test_illegal_super_new_with_extends_arguments;
  good_c g = new;
  also_c a = new;
  initial $display("x=%0d,%0d y=%0d", g.x, a.x, g.y);
endmodule
