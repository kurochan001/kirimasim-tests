/*
:name: test_default_argument_declaring_scope
:description: A default argument expression is evaluated in the scope that declares the subroutine, not in the calling scope (IEEE 1800-2023 Section 13.5.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3 23.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_argument_declaring_scope.expected
*/
// IEEE 1800-2023 §13.5.3: the default expression of an argument is evaluated
// in the scope that contains the subroutine declaration, each time a call
// uses the default. A function of instance u whose default is "a" reads u.a
// even when it is called from a module that has a variable a of its own, a
// class method's default reads the property a of its class, and the default
// is read again at each call, so it sees later changes of u.a.

class holder;
  int a = 7;
  function int m(int x, int b = a);
    return b;
  endfunction
endclass

module default_owner;
  int a = 8;
  function automatic int f(int x, int b = a);
    return b;
  endfunction
endmodule

module test_default_argument_declaring_scope;
  default_owner u ();
  int a = 100;
  holder h;

  initial begin
    h = new;
    #1;
    $display("h.m(1) = %0d, h.m(1, 2) = %0d", h.m(1), h.m(1, 2));
    $display("u.f(1) = %0d", u.f(1));
    u.a = 9;
    $display("u.f(1) after u.a = 9: %0d", u.f(1));
  end
endmodule
