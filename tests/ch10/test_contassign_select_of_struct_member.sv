/*
:name: test_contassign_select_of_struct_member
:description: Continuous assignments to bit-selects and part-selects of a member of a packed structure variable drive those bits (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 10.2 11.5.1 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_contassign_select_of_struct_member.expected
*/
// IEEE 1800-2023 §10.2, Table 10-1: the target of a continuous assignment
// (10.3) can be a bit-select or a part-select (11.5.1) of a variable,
// including of a member of a packed structure (7.2.1), with a constant or an
// indexed range. Each assignment drives only its bits and follows its
// right-hand side when it changes.

module test_contassign_select_of_struct_member;
  typedef struct packed {
    logic [15:0] w;
    logic [7:0] tag;
  } p_t;
  p_t pa, pb, pc, pd;
  logic [7:0] s = 8'h40;

  assign pa.w[0 +: 8] = s;
  assign pb.w[15 -: 8] = s;
  assign pc.w[7:0] = s;
  assign pd.w[3] = 1'b1;

  initial begin
    #1 $display("pa.w[7:0]=%h pb.w[15:8]=%h pc.w[7:0]=%h pd.w[3]=%b", pa.w[7:0], pb.w[15:8],
                pc.w[7:0], pd.w[3]);
    s = 8'h21;
    #1 $display("after s = 21: pa.w[7:0]=%h pb.w[15:8]=%h pc.w[7:0]=%h", pa.w[7:0], pb.w[15:8],
                pc.w[7:0]);
  end
endmodule
