/*
:name: test_nettype_alias_resolution_and_empty_drivers
:description: A chain of nettype aliases merges port drivers and undriven resolved nets evaluate their empty driver set (IEEE 1800-2023 Section 6.7.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.2 6.7.3 6.22.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_alias_resolution_and_empty_drivers.expected
*/
// IEEE 1800-2023 6.7.2 6.7.3 6.22.6: The same pure sum resolver is used through
// two aliases and on an undriven declaration; its nonzero bias makes time-zero
// resolution observable.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

package biased_net_pkg;
  function automatic real resolve(input real drivers[]);
    real total = 0.5;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction
  nettype real voltage with resolve;
  nettype voltage alias_one;
  nettype alias_one alias_two;
endpackage
module biased_driver import biased_net_pkg::*; #(parameter real V = 0.0)
  (output voltage output_net);
  assign output_net = V;
endmodule
module test_nettype_alias_resolution_and_empty_drivers;
  import biased_net_pkg::*;
  alias_two merged;
  voltage undriven;
  biased_driver #(.V(0.75)) first(merged);
  biased_driver #(.V(1.25)) second(merged);
  initial #1 $display("merged=%0.2f undriven=%0.2f", merged, undriven);
endmodule
