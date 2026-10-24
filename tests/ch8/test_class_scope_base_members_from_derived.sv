/*
:name: test_class_scope_base_members_from_derived
:description: inside a derived class, base_class::name selects the public and protected properties and methods of the base class, also those the derived class hides (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.23
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_scope_base_members_from_derived.expected
*/
// IEEE 1800-2023 §8.23: the class scope operator identifies a member of a
// particular class, and it gives a derived class access to the public and
// protected elements of its superclass.
// der_c declares its own pv and f, which hide the protected property pv and
// the non-virtual method f of base_c. via_scope reads base_c::pv, the public
// base_c::pub and the protected static base_c::ps and calls base_c::f, which
// are the members of base_c: 7 + 8 + 9 + 100. own uses the members of der_c:
// 70 + 200.
// In Verilator 5.052, base_c::f() calls the f of der_c, giving 224.
// Icarus Verilog 13.0 does not parse base_c:: inside the derived class.

class base_c;
  protected int pv = 7;
  int pub = 8;
  protected static int ps = 9;
  function int f();
    return 100;
  endfunction
endclass

class der_c extends base_c;
  int pv = 70;
  function int f();
    return 200;
  endfunction
  function int via_scope();
    return base_c::pv + base_c::pub + base_c::ps + base_c::f();
  endfunction
  function int own();
    return pv + f();
  endfunction
endclass

module test_class_scope_base_members_from_derived;
  der_c d;

  initial begin
    d = new;
    $display("base members through the scope: %0d, own members: %0d", d.via_scope(), d.own());
  end
endmodule
