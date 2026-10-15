/*
:name: test_generate_case_inside_for_label_minimal
:description: A labeled case generate construct inside a loop generate construct
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_case_inside_for_label_minimal.expected
*/
// A labeled case generate construct inside a loop generate construct (27.5)

module leaf6 #(parameter int P = 0)();
  localparam int VAL = P;
endmodule

module top;
  genvar i;
  generate
    for (i=0;i<4;i++) begin : G
      case (i)
        0: begin : C0 leaf6 #(.P(10)) u(); end
        1: begin : C1 leaf6 #(.P(11)) u(); end
        default: begin : CX leaf6 #(.P(99+i)) u(); end
      endcase
    end
  endgenerate

  initial begin
    if (G[0].C0.u.VAL !== 10) $fatal(1, "FAIL G0 C0");
    if (G[1].C1.u.VAL !== 11) $fatal(1, "FAIL G1 C1");
    if (G[2].CX.u.VAL !== 101) $fatal(1, "FAIL G2 CX");
    if (G[3].CX.u.VAL !== 102) $fatal(1, "FAIL G3 CX");
    $display("PASS: generate case inside for label minimal");
  end
endmodule
