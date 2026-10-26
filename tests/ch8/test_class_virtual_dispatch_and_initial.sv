/*
:name: test_class_virtual_dispatch_and_initial
:description: a virtual base method dispatches to the latest override, an initial override of a nonvirtual method stays static, and a class implements an interface class
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual_dispatch_and_initial.expected
*/
// IEEE 1800-2023 8.20: a virtual method defines the prototype that its
// overrides satisfy, an override may omit virtual once virtualness is
// inherited, and initial marks a method that is not a virtual override so a
// nonvirtual base method is called through a base handle. 8.26: an
// implementing method says virtual unless virtualness is inherited. The test
// overrides a virtual function in a chain, marks a nonvirtual method with
// initial, and calls an interface class method through a base handle.

interface class iclass;
  pure virtual function int f(int a);
endclass

class base;
  virtual function int f(int a);
    return a + 1;
  endfunction

  function int g(int a);
    return a + 2;
  endfunction
endclass

class mid extends base implements iclass;
  virtual function int f(int a);
    return a + 10;
  endfunction

  function :initial int g(int a);
    return a + 20;
  endfunction
endclass

class leaf extends mid;
  function int f(int a);
    return a + 100;
  endfunction
endclass

module test_class_virtual_dispatch_and_initial;
  base h;
  mid m;
  leaf l;
  iclass ih;

  initial begin
    m = new;
    l = new;
    h = l;
    $display("virtual=%0d", h.f(1));
    $display("base_g=%0d mid_g=%0d", h.g(1), m.g(1));
    ih = m;
    $display("interface=%0d", ih.f(1));
  end
endmodule
