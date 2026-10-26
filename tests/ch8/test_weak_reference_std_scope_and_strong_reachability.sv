/*
:name: test_weak_reference_std_scope_and_strong_reachability
:description: std declares weak_reference and another scope may declare its own class of that name, and a handle in an active scope keeps its referent strongly reachable
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.29 8.30.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_std_scope_and_strong_reachability.expected
*/
// IEEE 1800-2023 8.30.1: weak_reference is declared in package std, and a user
// declaration of that name in another scope may shadow it. 8.29: an object is
// strongly reachable while a class handle in an active scope refers to it, so
// its weak references are not cleared. The test uses std::weak_reference and a
// package class of the same name side by side, and checks that a weak
// reference still returns its referent while the only strong handle is alive.

package user_scope;
  class weak_reference #(type T = int);
    int marker = 42;
  endclass
endpackage

class target;
  int v;
endclass

module test_weak_reference_std_scope_and_strong_reachability;
  target o;
  std::weak_reference#(target) w;
  user_scope::weak_reference#(target) shadow;

  initial begin
    shadow = new;
    o = new;
    o.v = 1;
    w = new(o);
    $display("shadow_marker=%0d", shadow.marker);
    $display("referent_alive=%0d", w.get() != null);
    #1;
    $display("still_alive=%0d", w.get() != null);
    if (w.get() != null) $display("value=%0d", w.get().v);
  end
endmodule
