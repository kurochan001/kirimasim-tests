/*
:name: test_type_identity_per_instance_cast
:description: An unpacked structure type declared inside a module is a different type in each instance, so $cast between the variables of two instances fails, while the types from a package, from the compilation unit and from the instantiating module, and the type within one instance, can be cast (IEEE 1800-2023 Section 6.22)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22 6.24.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_identity_per_instance_cast.expected
*/
// IEEE 1800-2023 §6.22: the scope of a data type identifier includes the
// hierarchical instance, so each instance that declares a user-defined type
// creates a type of its own. Only a type imported from a package, or declared
// higher up in the compilation unit, is shared by several instances.
// The sub module declares the unpacked structure loc_t, and s1 and s2 are two
// instances of it. The variables vp, vu and vt have types from the package
// (6.22.1 h), from the compilation unit, and from the instantiating module
// through the type parameter PT (6.22.1 b); vl and wl have type loc_t.
// $cast called as a function (6.24.2) with arguments that are not singular,
// such as unpacked structures, returns 1 and assigns when the types are
// assignment compatible, and returns 0 and leaves the destination unchanged
// otherwise, without an error. For unpacked structures, assignment
// compatibility needs equivalent types (6.22.3), and two different unpacked
// structure types are equivalent only when they match (6.22.2). So the cast
// from s2.vl to s1.vl fails, as the two loc_t of s1 and s2 are different
// types, and s1.vl keeps 15; the cast from s1.vl to s1.wl, within s1,
// succeeds. If loc_t were one type for both instances, the cast from s2.vl
// would return 1 and copy 14.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures,
// and the 5.054 release of Verilator stops with an internal error at the
// first $cast of one, so the expected output follows the cited clauses alone.

package test_type_identity_per_instance_cast_pkg;
  typedef struct {int a;} pkg_t;
endpackage

typedef struct {int a;} test_type_identity_per_instance_cast_unit_t;

module test_type_identity_per_instance_cast_sub #(parameter type PT = int);
  typedef struct {int a;} loc_t;
  test_type_identity_per_instance_cast_pkg::pkg_t vp;
  test_type_identity_per_instance_cast_unit_t vu;
  PT vt;
  loc_t vl, wl;
endmodule

module test_type_identity_per_instance_cast;
  typedef struct {int a;} top_t;
  test_type_identity_per_instance_cast_sub #(.PT(top_t)) s1();
  test_type_identity_per_instance_cast_sub #(.PT(top_t)) s2();
  int ok_p, ok_u, ok_t, ok_l, ok_w;

  initial begin
    s2.vp.a = 11;
    s2.vu.a = 12;
    s2.vt.a = 13;
    s2.vl.a = 14;
    s1.vl.a = 15;
    ok_p = $cast(s1.vp, s2.vp);
    ok_u = $cast(s1.vu, s2.vu);
    ok_t = $cast(s1.vt, s2.vt);
    ok_l = $cast(s1.vl, s2.vl);
    ok_w = $cast(s1.wl, s1.vl);
    $display("package type, s2 to s1: cast=%0d a=%0d", ok_p, s1.vp.a);
    $display("unit type, s2 to s1: cast=%0d a=%0d", ok_u, s1.vu.a);
    $display("parameter type from top, s2 to s1: cast=%0d a=%0d", ok_t, s1.vt.a);
    $display("loc_t, s2 to s1: cast=%0d a=%0d", ok_l, s1.vl.a);
    $display("loc_t, within s1: cast=%0d a=%0d", ok_w, s1.wl.a);
  end
endmodule
