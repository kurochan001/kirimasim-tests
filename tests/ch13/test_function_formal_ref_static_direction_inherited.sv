/*
:name: test_function_formal_ref_static_direction_inherited
:description: a function formal without a direction after a ref static formal is ref static too, so it can be the target of a nonblocking assignment that updates the actual after the call (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_formal_ref_static_direction_inherited.expected
*/
// IEEE 1800-2023 13.4: after a formal with a direction, the following
// formals without one have the same direction, and the static qualifier of
// ref is part of it. 13.5.2: only a ref static formal may be used where an
// automatic variable may not, such as on the left of a nonblocking
// assignment; a plain ref formal may not, and neither may an input formal of
// an automatic function, which is an automatic variable (6.21). 13.4.4 allows
// a nonblocking assignment in a function called from an initial procedure.
//
// In set_next(ref static int p, q), q has no direction of its own, so it is
// ref static and refers to m_s; q <= p + 1 schedules m_s to become 6. Right
// after the call m_s is still 40, and one time unit later it is 6. If q were
// taken as plain ref or as an input, the design would be illegal, and a tool
// that ran it anyway with an input q would change only a local copy and
// leave m_s at 40.
//
// Icarus Verilog 13.0 does not parse ref static formals, and release 5.054
// of Verilator rejects them as unsupported.

module test_function_formal_ref_static_direction_inherited;
  int m_p = 5, m_s = 40;

  function automatic void set_next(ref static int p, q);
    q <= p + 1;
  endfunction

  initial begin
    set_next(m_p, m_s);
    $display("right after the call: m_s=%0d", m_s);
    #1;
    $display("after the nonblocking update: m_s=%0d", m_s);
  end
endmodule
