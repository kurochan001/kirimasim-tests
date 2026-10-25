/*
:name: test_syntax_instance_names_with_dimensions
:description: module instances with empty parentheses and with names that have no, one and two unpacked dimensions, where a packed connection is split over a one-dimensional array of instances and a connection of the port's size goes to every instance of a two-dimensional one (IEEE 1800-2023 Section 23.3.3.5)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.3.5 A.4.1.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_instance_names_with_dimensions.expected
*/
// IEEE 1800-2023 A.4.1.1: an instance is a name followed by zero or more
// unpacked dimensions, then parentheses that may hold no port connections.
// §23.3.3.5: a connection whose size matches the port goes to every
// instance of an array of instances; a packed connection wider than the
// port is split, the rightmost part going to the instance with the
// rightmost index and so on to the left.
//
// t0 has no ports and empty parentheses; s0 has no dimension. c1 [3:0]
// splits 8'b11_10_01_00, so c1[0] adds 1 to 00 and c1[3] to 11, and the
// outputs form py again from c1[3] down to c1[0]. c2 [1:0][3] has two
// dimensions, the second given by its size (indices 0 to 2); every element
// gets a = 1 and b = 2.
// Icarus Verilog 13.0 does not support arrays of instances with more than
// one dimension.

module adder2 (input logic [1:0] a, input logic [1:0] b, output logic [1:0] y);
  assign y = a + b;
endmodule

module tick;
  int n = 7;
endmodule

module test_syntax_instance_names_with_dimensions;
  logic [7:0] pa = 8'b11_10_01_00;
  wire [7:0] py;

  tick t0 ();
  adder2 s0 (.a(2'd1), .b(2'd1), .y());
  adder2 c1 [3:0] (.a(pa), .b(2'd1), .y(py));
  adder2 c2 [1:0][3] (.a(2'd1), .b(2'd2), .y());

  initial begin
    #1;
    $display("t0.n=%0d s0.y=%0d", t0.n, s0.y);
    $display("py=%b c1[0].y=%0d c1[1].y=%0d c1[3].y=%0d", py, c1[0].y, c1[1].y, c1[3].y);
    $display("c2[1][2].y=%0d c2[0][0].y=%0d", c2[1][2].y, c2[0][0].y);
  end
endmodule
