/*
:name: test_generate_if_else_hierarchy_minimal
:description: Unnamed if-else generate blocks each building a ripple-carry adder
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_if_else_hierarchy_minimal.expected
*/
// Unnamed if-else generate blocks each building a ripple-carry adder
module cell_min(input a,b,cin, output s,c); assign {c,s}=a+b+cin; endmodule

module gen_if_else_hierarchy_min #(parameter USE_ELSE=0, parameter W=4)(
  input  [W-1:0] x,y,
  output [W-1:0] s,
  output         c
);
  wire [W:0] carry; assign carry[0]=1'b0; assign c=carry[W];
  genvar i;
  if (!USE_ELSE) begin
    for (i=0;i<W;i++) begin
      cell_min u(.a(x[i]),.b(y[i]),.cin(carry[i]),.s(s[i]),.c(carry[i+1]));
    end
  end else begin
    for (i=0;i<W;i++) begin
      cell_min v(.a(x[i]),.b(y[i]),.cin(carry[i]),.s(s[i]),.c(carry[i+1]));
    end
  end
endmodule

module test_generate_if_else_hierarchy_minimal;
  localparam W=4;
  logic [W-1:0] x,y,s0,s1; logic c0,c1;
  gen_if_else_hierarchy_min #(.USE_ELSE(0),.W(W)) dut0(.x(x),.y(y),.s(s0),.c(c0));
  gen_if_else_hierarchy_min #(.USE_ELSE(1),.W(W)) dut1(.x(x),.y(y),.s(s1),.c(c1));
  initial begin
    x=4'h9; y=4'h7; #1;
    if ({c0,s0}!==(x+y)) $fatal(1,"dut0 mismatch");
    if ({c1,s1}!==(x+y)) $fatal(1,"dut1 mismatch");
    $display("TEST PASSED: generate if/else hierarchy minimal");
    $finish;
  end
endmodule
