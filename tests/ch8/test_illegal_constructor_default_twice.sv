/*
:name: test_illegal_constructor_default_twice
:description: the default keyword can appear at most once in a class constructor argument list (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor argument list of the class bad_c has the default keyword twice
:expected_stderr_regex: test_illegal_constructor_default_twice\.sv:48:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 9): the default keyword shall
// appear at most once in a class constructor argument list. In that list,
// default stands for the arguments of the superclass constructor (8.17).
// The class ok_c has the constructor arguments default and c, so new(5) gives a
// = 5 and c = 9, and new() gives the default values a = 4 and c = 9; the legal
// design prints 5 9 4 9. The constructor of bad_c, whose superclass constructor
// has no arguments, so that default stands for no argument and no name is
// repeated, lists default twice.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports default in a
// constructor argument list, and the errors they report do not count.

class test_illegal_constructor_default_twice_base_c;
  int a;
  function new(int a = 4);
    this.a = a;
  endfunction
endclass

class test_illegal_constructor_default_twice_ok_c
    extends test_illegal_constructor_default_twice_base_c;
  int c;
  function new(default, int c = 9);
    super.new(default);
    this.c = c;
  endfunction
endclass

class test_illegal_constructor_default_twice_empty_c;
  function new();
  endfunction
endclass

class test_illegal_constructor_default_twice_bad_c
    extends test_illegal_constructor_default_twice_empty_c;
  function new(default, default);   // illegal: default twice
  endfunction
endclass

module test_illegal_constructor_default_twice;
  test_illegal_constructor_default_twice_ok_c x, y;
  initial begin
    x = new(5);
    y = new();
    $display("%0d %0d %0d %0d", x.a, x.c, y.a, y.c);
  end
endmodule
