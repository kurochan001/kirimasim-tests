/*
:name: test_method_initial_extends
:description: A method declared :initial starts a method and does not override one, and a method declared :extends overrides a virtual method and is virtual itself (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_method_initial_extends.expected
*/
// IEEE 1800-2023 §8.20: :initial says that the method is not a virtual
// override; on the virtual method who of the base class it marks the first
// declaration, and on the non-virtual plain it does not make it virtual, so a
// subclass method of the same name hides it without overriding it. :extends
// says that the method overrides a virtual method, and makes it virtual without
// the keyword, so a call through a base handle reaches the subclass.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023.

class test_method_initial_extends_base;
  virtual function :initial string who();
    return "base who";
  endfunction
  function :initial string plain();
    return "base plain";
  endfunction
endclass

class test_method_initial_extends_derived extends test_method_initial_extends_base;
  function :extends string who();
    return "derived who";
  endfunction
  function string plain();
    return "derived plain";
  endfunction
endclass

module test_method_initial_extends;
  test_method_initial_extends_derived d = new;
  test_method_initial_extends_base b;
  initial begin
    b = d;
    $display("through the base: %s, %s", b.who(), b.plain());
    $display("through the subclass: %s, %s", d.who(), d.plain());
  end
endmodule
