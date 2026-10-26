/*
:name: test_extern_method_prototype_qualifiers
:description: an extern prototype carries the full arguments and the virtual, protected, local and final qualifiers, while the out-of-block body names the class and omits them
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_method_prototype_qualifiers.expected
*/
// IEEE 1800-2023 8.24: an out-of-block method needs an extern prototype in
// the class body with its full argument list, qualifiers and dynamic override
// specifiers, and the external definition qualifies the name with the class
// and omits those qualifiers and specifiers. D declares extern f (virtual
// override), h (protected), l (local), k (:final) and run (plain); each body
// is written as D::name without the qualifier. run, an out-of-block method of
// D, calls the protected h and the local l, which is allowed because a method
// of the class can see all its declarations. f dispatches virtually through a
// Base handle. A tool that requires the qualifier on the body, or that hides
// h or l from D::run, cannot elaborate or print the values.

class Base;
  virtual function int f(int x, int y);
    return x + y;
  endfunction
endclass

class D extends Base;
  extern virtual function int f(int x, int y);
  extern protected function void h(output int y);
  extern local function void l(output int y);
  extern function :final void k();
  extern function void run(output int a, output int b);
endclass

function int D::f(int x, int y);
  return x * 10 + y;
endfunction

function void D::h(output int y);
  y = 5;
endfunction

function void D::l(output int y);
  y = 6;
endfunction

function void D::k();
  $display("k");
endfunction

function void D::run(output int a, output int b);
  h(a);
  l(b);
endfunction

module test_extern_method_prototype_qualifiers;
  initial begin
    D d;
    Base b;
    int y, z;

    d = new;
    b = d;
    d.run(y, z);
    d.k();
    $display("f=%0d %0d hy=%0d lz=%0d", d.f(1, 2), b.f(3, 4), y, z);
  end
endmodule
