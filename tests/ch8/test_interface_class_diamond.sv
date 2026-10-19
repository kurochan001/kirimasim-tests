/*
:name: test_interface_class_diamond
:description: One method implements the methods of the same name that a class gets from several interface classes, also through a diamond of extends (IEEE 1800-2023 Section 8.26.6.1)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.6.1 8.26.6.3 8.26.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_diamond.expected
*/
// IEEE 1800-2023 §8.26.6.1: when a class must implement methods of the same
// name from several interface classes, one implementation provides all of them.
// §8.26.6.3: an interface class reached through two paths of extends (a
// diamond) is inherited once. So the same method runs whichever interface
// class handle it is called through.

interface class dia_base;
  pure virtual function int id();
endclass

interface class dia_left extends dia_base;
  pure virtual function int left();
endclass

interface class dia_right extends dia_base;
  pure virtual function int right();
endclass

interface class dia_other;
  pure virtual function int id();
endclass

class dia_impl implements dia_left, dia_right, dia_other;
  virtual function int id();
    return 1;
  endfunction
  virtual function int left();
    return 2;
  endfunction
  virtual function int right();
    return 3;
  endfunction
endclass

module test_interface_class_diamond;
  dia_impl obj;
  dia_left l;
  dia_right r;
  dia_other o;
  dia_base b1, b2;

  initial begin
    obj = new;
    l = obj;
    r = obj;
    o = obj;
    b1 = l;
    b2 = r;
    $display("left=%0d right=%0d", l.left(), r.right());
    $display("id via left=%0d via right=%0d via other=%0d", l.id(), r.id(), o.id());
    $display("id via base from left=%0d from right=%0d", b1.id(), b2.id());
  end
endmodule
