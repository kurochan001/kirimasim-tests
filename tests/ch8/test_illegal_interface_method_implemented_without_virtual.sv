/*
:name: test_illegal_interface_method_implemented_without_virtual
:description: A non-abstract class that implements an interface class method with a method declared without virtual, and inherits no virtual implementation, is an error (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: bad_c implements step_if, but its only step is declared without the keyword virtual and it inherits no virtual step
:expected_stderr_regex: test_illegal_interface_method_implemented_without_virtual\.sv:(45|46):
*/
// IEEE 1800-2023 §8.26: every pure virtual method of an implemented interface
// class needs a virtual method implementation in a non-abstract class, and
// the keyword virtual shall be used unless the virtual implementation is
// inherited. good_c declares step with virtual; inherit_c declares nothing
// and inherits the virtual step of vbase_c; both are legal. bad_c is not
// abstract, has no base class, and declares step without virtual. A tool can
// report the class or the method. With virtual added to bad_c::step the
// design prints 1 3 2.
// Icarus Verilog 13.0 does not support interface classes, so its syntax
// error does not count, and the 5.054 release of Verilator accepts the
// design.

interface class step_if;
  pure virtual function int step();
endclass

class good_c implements step_if;
  virtual function int step();
    return 1;
  endfunction
endclass

class vbase_c;
  virtual function int step();
    return 3;
  endfunction
endclass

class inherit_c extends vbase_c implements step_if;
endclass

class bad_c implements step_if;
  function int step();   // illegal: an implementation without virtual
    return 2;
  endfunction
endclass

module test_illegal_interface_method_implemented_without_virtual;
  good_c g;
  inherit_c i;
  bad_c b;
  step_if s1, s2, s3;

  initial begin
    g = new;
    i = new;
    b = new;
    s1 = g;
    s2 = i;
    s3 = b;
    $display("%0d %0d %0d", s1.step(), s2.step(), s3.step());
  end
endmodule
