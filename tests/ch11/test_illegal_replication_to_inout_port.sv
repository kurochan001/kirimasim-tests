/*
:name: test_illegal_replication_to_inout_port
:description: an expression that contains a replication cannot be connected to an inout port (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inout port io of the instance u_bad is connected to the replication {2{w}}
:expected_stderr_regex: test_illegal_replication_to_inout_port\.sv:29:
*/
// IEEE 1800-2023 §11.4.12.1: expressions that contain replications shall not
// be connected to output or inout ports. The inout port of u_ok is connected
// to the concatenation of nets {w1, w0}, which is legal; the inout port of
// u_bad is connected to {2{w}}.
// The 5.052 release of Verilator reports the replication as an unsupported
// tristate construct, which does not count.

module bidir_m (inout wire [1:0] io);
  assign io = 2'b01;
endmodule

module test_illegal_replication_to_inout_port;
  wire w1, w0, w;

  bidir_m u_ok (.io({w1, w0}));
  bidir_m u_bad (.io({2{w}}));   // illegal: a replication connected to an inout

  initial #1 $display("%b %b", w1, w0);
endmodule
