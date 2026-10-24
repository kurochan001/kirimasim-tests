/*
:name: test_illegal_replication_to_output_port
:description: an expression that contains a replication cannot be connected to an output port (IEEE 1800-2023 Section 11.4.12.1)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output port o of the instance u_bad is connected to the replication {2{w}}
:expected_stderr_regex: test_illegal_replication_to_output_port\.sv:33:
*/
// IEEE 1800-2023 §11.4.12.1: expressions that contain replications shall not
// be connected to output or inout ports. The output of u_ok goes to the
// concatenation {w1, w0}, and a replication drives the input of u_in, which
// is legal; the output of u_bad is connected to {2{w}}.
// The design is accepted by the 5.052 release of Verilator.

module out_m (output wire [1:0] o);
  assign o = 2'b10;
endmodule

module in_m (input wire [1:0] i);
endmodule

module test_illegal_replication_to_output_port;
  wire w1, w0, w;
  logic a = 1'b1;

  out_m u_ok (.o({w1, w0}));
  in_m u_in (.i({2{a}}));
  out_m u_bad (.o({2{w}}));   // illegal: a replication connected to an output

  initial #1 $display("%b %b", w1, w0);
endmodule
