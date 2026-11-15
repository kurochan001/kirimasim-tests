/*
:name: test_task_formal_inherits_ref_static_nonblocking
:description: A task formal with no direction after a ref static formal is ref static too, so it can be the target of a nonblocking assignment, which updates its actual in the nonblocking assignment region (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_formal_inherits_ref_static_nonblocking.expected
*/
// IEEE 1800-2023 §13.3: a formal with no direction takes the direction of the
// formal before it, and the static qualifier of ref static is part of that
// direction. §13.5.2 and §6.21: a ref formal without static cannot be the
// target of a nonblocking assignment, and a ref static one can.
//
// In put(ref static int p, q, input int v), q has no direction, so it is ref
// static like p (and an int, the type of p). put writes p and q with
// nonblocking assignments; the design is legal only because q kept the
// static qualifier. The writes take effect in the nonblocking assignment
// region of the time step, after the line printed right after the call, so
// m1 and m2 are still 0 there and are 5 and 6 one time unit later. The call
// also leaves m3, which is not an actual, at 0.
// The expected output follows the standard alone: Icarus Verilog 13.0 does
// not support ref ports, and the 5.054 release of Verilator does not support
// ref static ones.

module test_task_formal_inherits_ref_static_nonblocking;
  int m1, m2, m3;

  task automatic put(ref static int p, q, input int v);
    p <= v;
    q <= v + 1;
  endtask

  initial begin
    m1 = 0;
    m2 = 0;
    m3 = 0;
    put(m1, m2, 5);
    $display("after call: m1=%0d m2=%0d m3=%0d", m1, m2, m3);
    #1;
    $display("one step later: m1=%0d m2=%0d m3=%0d", m1, m2, m3);
  end
endmodule
