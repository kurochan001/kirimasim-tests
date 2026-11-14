/*
:name: test_illegal_constructor_wait_statement
:description: A class constructor cannot contain a wait statement, because new is a function and shall be nonblocking (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.7
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor of waiting_c contains the wait statement wait (go)
:expected_stderr_regex: test_illegal_constructor_wait_statement\.sv:38:
*/
// IEEE 1800-2023 §8.7: the constructor new is a function with no return
// type, and like any other function it shall be nonblocking, so it cannot
// suspend the process that creates the object. A wait statement would do
// that when its condition is false. The constructor of ready_c only assigns
// its property, which is legal; the constructor of waiting_c waits until its
// property go is 1 before it assigns its other property. Without the wait
// statement the design prints 1 2.
// test_illegal_constructor_delay_control and
// test_illegal_constructor_event_control check the other two forms of
// timing control.
// Icarus Verilog 13.0 and the 5.054 release of Verilator both report on the
// marked line that the timing control is not allowed in a function.

class ready_c;
  int v;
  function new(int x);
    v = x;
  endfunction
endclass

class waiting_c;
  bit go;
  int v;
  function new(int x);
    wait (go) v = x;   // illegal: a wait statement in a constructor
  endfunction
endclass

module test_illegal_constructor_wait_statement;
  ready_c r;
  waiting_c w;

  initial begin
    r = new(1);
    w = new(2);
    $display("%0d %0d", r.v, w.v);
  end
endmodule
