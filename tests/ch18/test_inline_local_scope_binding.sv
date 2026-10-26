/*
:name: test_inline_local_scope_binding
:description: In randomize() with, local:: bypasses the receiver class and resolves in the scope of the call, including a wildcard-imported package name, a type name and a class scope, while local::obj with the object handle name binds to the scope of the receiver class (IEEE 1800-2023 Section 18.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inline_local_scope_binding.expected
*/
// IEEE 1800-2023 §18.7.1: unqualified names in an unrestricted inline
// constraint are resolved first in the receiver class and then in the scope of
// the call; local:: bypasses the receiver class and resolves in the scope of
// the call, and it may qualify class scopes and type names. With a wildcard
// package import, local::a is the unqualified a of the local scope. For a call
// obj.randomize() with, the name local::obj binds to the scope of the receiver
// class.
//
// The receiver class lr_recv has a random member lim constrained to 8, a
// member loc_int, a member lr_scope and a static member r with the value 11.
// The module imports lp::* (lim is 4), typedefs loc_int and declares the class
// loc_scope with sv 9, and its variable r is the receiver object. Thus an
// unqualified lim is the member 8, local::lim is the package 4, local::loc_int
// is the local typedef even though the class has a member of that name, and
// local::lr_scope::sv is the local class scope. local::r is the static member
// of the receiver class (11), not the module variable that holds the object.
// A tool that does not let local:: bypass the receiver class fails the call
// or finds another value at each of the four checks.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052 does
// not support local:: type and class-scope names or local:: on the receiver
// name, so the expected values come from the cited clause.

package lp;
  int lim = 4;
endpackage

class lr_scope;
  static int sv = 9;
endclass

class lr_recv;
  rand int a;
  rand int lim;
  rand int loc_int;
  rand int lr_scope;
  static int r = 11;

  constraint c_lim { lim == 8; }
  constraint c_loc { loc_int == 3; }
  constraint c_scope { lr_scope == 5; }
endclass

module test_inline_local_scope_binding;
  import lp::*;

  typedef int loc_int;
  lr_recv r;
  int ok_member, ok_import, ok_type, ok_scope, ok_receiver;
  int a_member, a_import, a_type, a_scope, a_receiver;

  initial begin
    r = new;
    ok_member = r.randomize() with { a == lim; };
    a_member = r.a;
    ok_import = r.randomize() with { a == local::lim; };
    a_import = r.a;
    ok_type = r.randomize() with { a == local::loc_int'(7); };
    a_type = r.a;
    ok_scope = r.randomize() with { a == local::lr_scope::sv; };
    a_scope = r.a;
    ok_receiver = r.randomize() with { a == local::r; };
    a_receiver = r.a;
    $display("member lim %0d a=%0d, package local::lim %0d a=%0d",
             ok_member, a_member, ok_import, a_import);
    $display("local:: type a=%0d, local:: class scope a=%0d", a_type, a_scope);
    $display("local:: receiver name a=%0d", a_receiver);
  end
endmodule
