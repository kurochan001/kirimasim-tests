/*
:name: test_ch6_extra_localparam_sticky
:description: In a parameter port list, a declaration after localparam stays local until the next parameter keyword, so it cannot be overridden by name (IEEE 1800-2023 Section 6.20.4)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.4 23.10.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance overrides B by name, but B follows a localparam in the port list and is local
:expected_stderr_regex: test_ch6_extra_localparam_sticky\.sv:27:
*/
// IEEE 1800-2023 §6.20.4: in a parameter port list, every parameter
// declaration between a localparam keyword and the next parameter keyword (or
// the end of the list) is a local parameter. A and D are overridable; L is
// explicitly local; the declaration of B has no keyword of its own and
// follows L, so B is local too. The instance on the marked line overrides B,
// which is illegal (§23.10.2.2).

module test_ch6_extra_localparam_sticky_cell
  #(parameter int A = 1, localparam int L = 2, int B = 3, parameter int D = 4) ();
  initial $display("A=%0d L=%0d B=%0d D=%0d", A, L, B, D);
endmodule

module test_ch6_extra_localparam_sticky;
  test_ch6_extra_localparam_sticky_cell #(.A(1), .B(9), .D(4)) u();
endmodule
