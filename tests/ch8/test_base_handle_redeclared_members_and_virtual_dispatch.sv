/*
:name: test_base_handle_redeclared_members_and_virtual_dispatch
:description: through a base-class handle to a derived object, a redeclared property and a nonvirtual method resolve to the base class, and only a virtual method calls the derived override (IEEE 1800-2023 Section 8.14)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.14 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_base_handle_redeclared_members_and_virtual_dispatch.expected
*/
// IEEE 1800-2023 §8.14: a variable of a base class type may hold the handle of
// a derived object. References through it reach the members of the base
// class; a property or a method that the derived class declares again is
// hidden from that handle. To reach the derived version of a method through
// the base handle, the method has to be virtual (8.20).
//
// base_c and derived_c both declare the property val and the methods
// plain_get (not virtual) and virt_get (virtual), each returning val plus a
// different constant. One derived object is reached through the base handle b
// and its own handle d; a base object bo is the control for virt_get. A write
// to b.val has to reach the val of base_c, which derived_c::base_val reads
// through super, and leave the val of derived_c alone.
// Icarus Verilog 13.0 calls base_c::virt_get through b, so its third line
// shows b=12; the virtual method has to dispatch to derived_c::virt_get.

class base_c;
  int val = 10;
  function int plain_get();
    return val + 1;
  endfunction
  virtual function int virt_get();
    return val + 2;
  endfunction
endclass

class derived_c extends base_c;
  int val = 50;
  function int plain_get();
    return val + 3;
  endfunction
  virtual function int virt_get();
    return val + 4;
  endfunction
  function int base_val();
    return super.val;
  endfunction
endclass

module test_base_handle_redeclared_members_and_virtual_dispatch;
  derived_c d;
  base_c b, bo;

  initial begin
    d = new;
    b = d;
    bo = new;
    $display("val: b=%0d d=%0d", b.val, d.val);
    $display("plain_get: b=%0d d=%0d", b.plain_get(), d.plain_get());
    $display("virt_get: b=%0d d=%0d bo=%0d", b.virt_get(), d.virt_get(), bo.virt_get());
    b.val = 20;
    $display("after b.val=20: base_val=%0d d.val=%0d b.plain_get=%0d b.virt_get=%0d",
             d.base_val(), d.val, b.plain_get(), b.virt_get());
  end
endmodule
