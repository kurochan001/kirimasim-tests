/*
:name: test_illegal_virtual_interface_component_in_always_event_control
:description: A component of an interface reached through a virtual interface cannot be used in the sensitivity list of an always procedure, while the same event control in an initial procedure is a procedural statement and is legal (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the event control of the always procedure names the component clk through the virtual interface v
:expected_stderr_regex: test_illegal_virtual_interface_component_in_always_event_control\.sv:33:
*/
// IEEE 1800-2023 §25.9: the components of an interface instance are
// available through an initialized virtual interface only in procedural
// statements; they cannot be used in sensitivity lists. The event control at
// the head of the always procedure is its sensitivity list (9.4.2), so it
// cannot name v.clk. The same event control inside the fork of the initial
// procedure is a procedural statement, which is legal.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.054
// release of Verilator accepts the design.

interface vev_if;
  logic clk = 1'b0;
endinterface

module test_illegal_virtual_interface_component_in_always_event_control;
  vev_if bus ();
  virtual vev_if v;
  int n = 0;

  always @(posedge v.clk) n++;   // illegal: a virtual interface component in a sensitivity list

  initial begin
    v = bus;
    fork
      @(posedge v.clk) $display("initial saw the edge");
      #1 bus.clk = 1'b1;
    join
  end
endmodule
