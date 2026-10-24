/*
:name: test_illegal_interface_method_conflict_with_inherited
:description: the method that implements an interface method has also to be a valid override of an inherited method of the same name (IEEE 1800-2023 Section 8.26.6.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.6.1 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method pick of ext_c, which implements pick_if::pick with two arguments, does not validly override the inherited virtual pick with one argument
:expected_stderr_regex: test_illegal_interface_method_conflict_with_inherited\.sv:(44|45):
*/
// IEEE 1800-2023 §8.26.6.1: a method that resolves a name conflict shall
// implement all the interface methods of that name and also be a valid
// virtual method override (8.20) of any inherited method of the same name.
// ext_c inherits a virtual pick with one argument from base_c and has to
// implement pick_if::pick with two; its pick matches pick_if but changes the
// arguments of the virtual method of base_c. ok_c, whose base and interface
// agree, is legal. A tool can report the method or the class.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class pick_if;
  pure virtual function int pick(int a, int b);
endclass

interface class one_if;
  pure virtual function int pick(int a);
endclass

class base_c;
  virtual function int pick(int a);
    return a;
  endfunction
endclass

class ok_c extends base_c implements one_if;
  virtual function int pick(int a);
    return a + 1;
  endfunction
endclass

class ext_c extends base_c implements pick_if;   // (or reported here)
  virtual function int pick(int a, int b);   // illegal: not a valid override of base_c::pick
    return a + b;
  endfunction
endclass

module test_illegal_interface_method_conflict_with_inherited;
  ok_c o = new;
  initial $display("%0d", o.pick(1));
endmodule
