/*
:name: test_nettype_rename_matches
:description: A nettype declared as a new name for a user-defined nettype matches it, so a net of the new name connects to a port of the original nettype (IEEE 1800-2023 Section 6.22.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.6 6.6.7 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_rename_matches.expected
*/
// IEEE 1800-2023 §6.22.6: a nettype matches itself, and a simple nettype that
// renames a user-defined nettype matches that nettype. volt_net is a
// user-defined nettype of real (6.6.7) and volt_alias another name for it.
// §23.3.3: the two sides of a port of user-defined nettypes have to match and
// are merged into one net, so the net n of volt_alias can be connected to the
// volt_net output port of the driver and carries its value.

package test_nettype_rename_matches_pkg;
  nettype real volt_net;
  nettype volt_net volt_alias;
endpackage

module test_nettype_rename_matches_driver
  import test_nettype_rename_matches_pkg::*;
  (output volt_net o);
  assign o = 1.5;
endmodule

module test_nettype_rename_matches;
  import test_nettype_rename_matches_pkg::*;

  volt_alias n;

  test_nettype_rename_matches_driver d(n);

  initial #1 $display("n=%0.1f", n);
endmodule
