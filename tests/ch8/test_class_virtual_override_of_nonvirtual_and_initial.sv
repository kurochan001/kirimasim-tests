/*
:name: test_class_virtual_override_of_nonvirtual_and_initial
:description: a virtual method can override a non-virtual one and stays virtual in later overrides without the keyword, overrides follow the prototype of the virtual method, and a method declared :initial is not made virtual by it, so a non-virtual override of it is chosen by the handle type (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual_override_of_nonvirtual_and_initial.expected
*/
// IEEE 1800-2023 §8.20: a virtual method may override a non-virtual method;
// once virtual, a method remains virtual in every subclass that overrides it,
// with or without the virtual keyword. A virtual method gives the prototype
// (access, arguments with their directions, return type) that its overrides
// keep. The :initial specifier says that a method is not a virtual override,
// and it does not make the method virtual, so a subclass may override it
// without being virtual.
// The object o is a c2_c, reached through handles of c0_c, c1_c and c2_c.
// who is non-virtual in c0_c and virtual from c1_c on, so only the c0_c
// handle calls the c0_c version. scale is virtual with an output argument,
// and every handle calls the c2_c override. ini is declared :initial and not
// virtual in c0_c and overridden in c1_c, so each handle calls the version of
// its own class.
// Icarus Verilog 13.0 does not support the :initial specifier.

class c0_c;
  function string who();
    return "c0";
  endfunction
  function :initial string ini();
    return "c0 ini";
  endfunction
  virtual function int scale(int k, output int extra);
    extra = k;
    return k + 1;
  endfunction
endclass

class c1_c extends c0_c;
  virtual function string who();
    return "c1";
  endfunction
  function string ini();
    return "c1 ini";
  endfunction
  virtual function int scale(int k, output int extra);
    extra = 2 * k;
    return k + 2;
  endfunction
endclass

class c2_c extends c1_c;
  function string who();
    return "c2";
  endfunction
  function int scale(int k, output int extra);
    extra = 3 * k;
    return k + 3;
  endfunction
endclass

module test_class_virtual_override_of_nonvirtual_and_initial;
  c0_c h0;
  c1_c h1;
  c2_c o;
  int r0, r1, e0, e1;

  initial begin
    o = new;
    h0 = o;
    h1 = o;
    $display("who: c0 handle=%s c1 handle=%s c2 handle=%s", h0.who(), h1.who(), o.who());
    r0 = h0.scale(5, e0);
    r1 = h1.scale(5, e1);
    $display("scale: c0 handle=%0d,%0d c1 handle=%0d,%0d", r0, e0, r1, e1);
    $display("ini: c0 handle=%s c1 handle=%s c2 handle=%s", h0.ini(), h1.ini(), o.ini());
  end
endmodule
