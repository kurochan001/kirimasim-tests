/*
:name: test_generate_for_if_label_ref_minimal
:description: An if generate construct inside a loop generate construct, selecting per bit
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for_if_label_ref_minimal.expected
*/
// An if generate construct inside a loop generate construct, selecting per bit
module gen_for_if_label #(parameter W=6)(
  input  logic [W-1:0] x,
  input  logic [W-1:0] y,
  output logic [W-1:0] s
);
  genvar i;
  for (i=0;i<W;i++) begin: G
    if ((i%2)==0) begin: EVEN
      assign s[i] = x[i];
    end else begin: ODD
      assign s[i] = y[i];
    end
  end
endmodule

module test_generate_for_if_label_ref_minimal;
  localparam int W=6;
  logic [W-1:0] x,y,s;
  gen_for_if_label #(.W(W)) dut(.x(x),.y(y),.s(s));
  initial begin
    x = 6'b000100; // even bits 0,2,4 = 0,1,0
    y = 6'b100000; // odd  bits 1,3,5 = 0,0,1
    #1;
    // Expect s[even]=x[even], s[odd]=y[odd]
    // s[0]=x[0]=0, s[1]=y[1]=0, s[2]=x[2]=1, s[3]=y[3]=0, s[4]=x[4]=0, s[5]=y[5]=1
    if (s !== 6'b100100) $fatal(1, "for+if label minimal mismatch: %b", s);
    $display("TEST PASSED: generate for+if label minimal");
    $finish;
  end
endmodule
