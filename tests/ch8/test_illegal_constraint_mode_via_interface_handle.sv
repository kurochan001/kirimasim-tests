/*
:name: test_illegal_constraint_mode_via_interface_handle
:description: constraint_mode cannot be called through an interface class handle (IEEE 1800-2023 Section 8.26.9)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: constraint_mode is called on a handle of the interface class rnd_if
:expected_stderr_regex: test_illegal_constraint_mode_via_interface_handle\.sv:42:
*/
// IEEE 1800-2023 §8.26.9: randomize() may be called on an interface class
// handle, but rand_mode and constraint_mode shall not be used through one,
// since interface classes cannot have data members or constraints. h is a
// handle of the interface class rnd_if to an object of impl, which has a
// constraint. Icarus Verilog 13.0 does not support interface classes, so
// the syntax errors it reports do not count.
// The 5.052 release of Verilator stops with an internal fault, which does
// not count as a rejection of the design.

module test_illegal_constraint_mode_via_interface_handle;
  interface class rnd_if;
    pure virtual function int get();
  endclass

  class impl implements rnd_if;
    rand int x;
    constraint small_c { x < 10; }
    virtual function int get();
      return x;
    endfunction
  endclass

  impl o;
  rnd_if h;

  initial begin
    o = new;
    h = o;
    h.constraint_mode(0);   // illegal: constraint_mode through an interface class handle
  end
endmodule
