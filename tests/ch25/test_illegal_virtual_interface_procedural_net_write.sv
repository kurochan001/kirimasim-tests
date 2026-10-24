/*
:name: test_illegal_virtual_interface_procedural_net_write
:description: A net of an interface cannot be driven through a virtual interface by a procedural assignment; the interface has to provide a variable that drives the net, which the virtual interface can write (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure assigns the net n of the interface through the virtual interface v
:expected_stderr_regex: test_illegal_virtual_interface_procedural_net_write\.sv:37:
*/
// IEEE 1800-2023 §25.9: the components reached through a virtual interface
// can only be used in procedural statements, so for a net to be driven via a
// virtual interface, the interface itself has to provide a procedural means,
// such as a variable that a continuous assignment inside the interface copies
// to the net. vpn_if drives the net n from the variable n_drv. Writing v.n_drv
// is legal; writing v.n is not.
// Icarus Verilog 13.0 does not support virtual interfaces and reports
// syntax errors on their declarations, which do not count. The 5.052
// release of Verilator accepts the design.

interface vpn_if;
  logic n_drv = 1'b0;
  wire n;
  assign n = n_drv;
endinterface

module test_illegal_virtual_interface_procedural_net_write;
  vpn_if bus ();
  virtual vpn_if v;
  initial begin
    v = bus;
    v.n_drv = 1'b1;
    #1 $display("%b", bus.n);
    v.n = 1'b0;   // illegal: a procedural assignment to a net through v
  end
endmodule
