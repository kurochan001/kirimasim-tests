/*
:name: test_nettype_matches_itself_across_ports
:description: a nettype matches itself, so nets declared with it in different modules connect through ports of that nettype and merge into one net resolved over all their drivers (IEEE 1800-2023 Section 6.22.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.6 6.6.7 23.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_matches_itself_across_ports.expected
*/
// IEEE 1800-2023 §6.22.6: a nettype matches itself and the nettype of the
// nets declared with it, within the scope of its name. §23.3.3: when both
// sides of a port connection are of user-defined nettypes, they shall be of
// matching nettypes and are merged into one simulated net. sum_net (§6.6.7)
// resolves its drivers by adding them. The net n of the top module, the
// output ports of three driver instances and the inout port of nmp_pass,
// all declared with sum_net, form one net whose value is 1 + 2 + 4 = 7; the
// second net m, with only one driver, is 5.
// Icarus Verilog 13.0 and Verilator 5.052 do not support user-defined
// nettypes with a resolution function (unsupported construct).

package nmp_pkg;
  function automatic int add_all(input int drivers[]);
    int total = 0;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction
  nettype int sum_net with add_all;
endpackage

module nmp_drv import nmp_pkg::*; #(parameter int V = 0) (output sum_net o);
  assign o = V;
endmodule

module nmp_pass import nmp_pkg::*; (inout sum_net p);
  nmp_drv #(.V(4)) d (p);
endmodule

module test_nettype_matches_itself_across_ports;
  import nmp_pkg::*;
  sum_net n, m;
  nmp_drv #(.V(1)) a (n);
  nmp_drv #(.V(2)) b (n);
  nmp_pass c (n);
  nmp_drv #(.V(5)) e (m);
  initial #1 $display("n=%0d m=%0d", n, m);
endmodule
