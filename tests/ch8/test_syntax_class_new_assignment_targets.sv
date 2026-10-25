/*
:name: test_syntax_class_new_assignment_targets
:description: blocking assignments of class new to a plain handle, a this. member, a class-scoped static member, a package-scoped variable and selected array elements, with new(args), a typed D::new(args) and a shallow copy new h (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 8.8 8.9 8.11 8.12 A.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_class_new_assignment_targets.expected
*/
// IEEE 1800-2023 A.6.2: a blocking assignment can assign class_new to a
// variable, optionally prefixed with this. (or super.), a class scope or a
// package scope, followed by a select. §8.7: new(args) creates an object and
// runs its constructor with the arguments. §8.8: D::new(args) creates an
// object of the class D for a handle of a base class. §8.12: new h makes a
// shallow copy of the object h refers to, a separate object.
//
// The targets are h, this.peer and arr[1] inside a method, the static member
// C::sh, the package variable pk::ph and the element hs[2]. Each object's v
// shows which constructor ran with which argument, and changing the copy cp
// leaves the original unchanged.
// Icarus Verilog 13.0 rejects the class-scoped target C::sh and the
// package-scoped target pk::ph of a class new (syntax errors).

package pk;
  class P;
    int v;
    function new(int x);
      v = x;
    endfunction
  endclass
  P ph;
endpackage

class C;
  int v;
  static C sh;
  C peer;
  C arr[2];
  function new(int x = 0);
    v = x;
  endfunction
  function void build();
    this.peer = new(v + 10);
    arr[1] = new(v + 20);
  endfunction
endclass

class D extends C;
  function new(int x);
    super.new(x * 2);
  endfunction
endclass

module test_syntax_class_new_assignment_targets;
  C h, hd, cp;
  C hs[3];
  D dh;

  initial begin
    h = new(5);
    h.build();
    $display("h.v=%0d peer.v=%0d arr[1].v=%0d arr[0]=%0d", h.v, h.peer.v, h.arr[1].v,
             h.arr[0] == null);
    C::sh = new(7);
    pk::ph = new(9);
    hs[2] = new(3);
    $display("C::sh.v=%0d pk::ph.v=%0d hs[2].v=%0d hs[1]=%0d", C::sh.v, pk::ph.v, hs[2].v,
             hs[1] == null);
    hd = D::new(4);
    $display("hd.v=%0d is_D=%0d", hd.v, $cast(dh, hd));
    cp = new hd;
    cp.v = 1;
    $display("cp.v=%0d hd.v=%0d same=%0d", cp.v, hd.v, cp == hd);
  end
endmodule
