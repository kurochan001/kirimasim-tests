/*
:name: test_vpi_constraint_properties
:description: Each class definition gives its constraints in syntactic declaration order, extern at its prototype position, and each constraint gives vpiAllocScheme vpiOtherScheme and vpiAutomatic FALSE only for a static constraint (IEEE 1800-2023 Sections 37.34, 37.3.7)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.34 37.3.7 18.5.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_constraint_properties.c
:expected_stdout: @test_vpi_constraint_properties.expected
*/
// IEEE 1800-2023 §37.34: a constraint is an object with the Boolean
// vpiAutomatic property, which is FALSE only when the constraint was declared
// static (detail 1). A class definition's vpiConstraint iteration returns the
// normal constraints in syntactic declaration order, with an extern
// constraint at the position of its prototype (detail 4). §37.3.7:
// vpiAllocScheme is vpiAutomaticScheme for an object allocated in a frame or
// thread, vpiDynamicScheme for one in dynamic memory, and vpiOtherScheme for
// all other objects; a constraint is not allocated in either of the first two
// ways, so it returns vpiOtherScheme. The classes are sorted by name because
// their iteration order is not fixed; the constraints of a class are printed
// in declaration order.

module test_vpi_constraint_properties;
  class cp_c;
    rand int x;
    constraint c_norm { x > 0; }
    static constraint c_static { x < 10; }
    extern constraint c_ext;
  endclass

  constraint cp_c::c_ext { x != 5; }

  virtual class cp_v;
    pure constraint c_pure;
  endclass

  initial #1 $vt_cons;
endmodule
