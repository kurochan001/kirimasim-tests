/*
:name: test_illegal_interface_port_actual_through_generate_block
:description: A hierarchical reference used as the actual of an interface port cannot resolve through a generate block (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual of the interface port b of u is the interface bus inside the generate block g
:expected_stderr_regex: test_illegal_interface_port_actual_through_generate_block\.sv:40:
*/
// IEEE 1800-2023 §25.3: when the actual of an interface port connection is a
// hierarchical reference to an interface, it shall refer to an interface
// instance and shall not resolve through an arrayed instance or a generate
// block. The instance ok takes the interface bus inside the module instance
// one, which is legal; u takes the one inside the named generate block g.
// Oracle checks: Icarus Verilog 13.0 does not support interface ports and stops
// at the header of a module that has one; the 5.052 release of Verilator
// accepts the design.

interface hig_if;
  logic s;
endinterface

module hig_holder;
  hig_if bus ();
endmodule

module hig_user(hig_if b);
endmodule

module test_illegal_interface_port_actual_through_generate_block;
  hig_holder one ();
  if (1) begin : g
    hig_if bus ();
  end
  hig_user ok (.b(one.bus));
  hig_user u (.b(g.bus));   // illegal: through the generate block g
endmodule
