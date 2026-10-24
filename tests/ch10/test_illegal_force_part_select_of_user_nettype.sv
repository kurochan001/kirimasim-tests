/*
:name: test_illegal_force_part_select_of_user_nettype
:description: a force cannot be applied to a part-select of a net of a user-defined nettype, although it can force the whole net (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force statement writes pn[3:0], a part-select of the net pn of the user-defined nettype pair_net
:expected_stderr_regex: test_illegal_force_part_select_of_user_nettype\.sv:36:
*/
// IEEE 1800-2023 §10.6.2: the left-hand side of a force can be a constant
// part-select of a vector net, but shall not be a bit-select or part-select of
// a net with a user-defined nettype. The force of the whole net pn and of the
// part-select wv[3:0] of a wire are legal; the force of pn[3:0] is not.
// Icarus Verilog 13.0 gives a syntax error at the nettype declaration, and
// the 5.052 release of Verilator reports nettype as unsupported, so neither
// error counts.

typedef struct packed {
  logic [3:0] hi;
  logic [3:0] lo;
} pair_t;

nettype pair_t pair_net;

module test_illegal_force_part_select_of_user_nettype;
  pair_net pn;
  wire [7:0] wv = 8'h00;

  initial begin
    force pn = '{hi: 4'h1, lo: 4'h2};
    force wv[3:0] = 4'h3;
    force pn[3:0] = 4'h4;   // illegal: part-select of a user-defined nettype net
    #1 $display("%h %h", pn, wv);
  end
endmodule
