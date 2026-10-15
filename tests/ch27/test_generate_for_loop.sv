/*
:name: test_generate_for_loop
:description: A ripple-carry adder built with a generate for loop
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.3.2 16.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_for_loop.expected
*/
// A ripple-carry adder built with a generate for loop
module full_adder(input a, b, cin, output sum, cout);
  assign {cout, sum} = a + b + cin;
endmodule

module parameterized_adder #(parameter WIDTH = 8)(
  input  [WIDTH-1:0] a, b,
  input              cin,
  output [WIDTH-1:0] sum,
  output             cout
);
  wire [WIDTH:0] carry;
  assign carry[0] = cin;
  assign cout = carry[WIDTH];

  genvar i;
  generate
    for (i = 0; i < WIDTH; i++) begin : gen_add
      full_adder fa(.a(a[i]), .b(b[i]), .cin(carry[i]), .sum(sum[i]), .cout(carry[i+1]));
    end
  endgenerate
endmodule

module test_generate_for_loop;
  localparam int W = 8;
  logic [W-1:0] a, b, sum;
  logic cin, cout;

  parameterized_adder #(.WIDTH(W)) dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    // Simple vectors
    a = 8'h15; b = 8'h27; cin = 0; #1;
    assert({cout, sum} == (a + b + cin));

    a = 8'hFF; b = 8'h01; cin = 0; #1;
    assert({cout, sum} == 9'h100);

    a = 8'h0F; b = 8'h01; cin = 1; #1;
    assert({cout, sum} == (a + b + cin));

    $display("Generate for-loop adder test PASSED");
    $finish;
  end
endmodule
