/*
:name: test_net_array_elements_and_whole_array_assign
:description: elements of a net array are used as vector nets in continuous assignments, expressions and port connections, and a whole net array is assigned from a variable array and back, element by element from left to right (IEEE 1800-2023 Sections 7.4.2, 7.6)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_array_elements_and_whole_array_assign.expected
*/
// IEEE 1800-2023 §7.4.2: an element of a net array can be used like a scalar
// or vector net. Here the elements of w are driven by continuous assignments,
// one by two assignments to its two halves, read in an expression, and
// connected to an input and an output port of a module instance.
// §7.6: an array of nets can be assigned from an array of variables, and an
// array of variables from an array of nets, when their types are assignment
// compatible; elements correspond from left to right whatever their indices.
// wa [0:3] takes v [1:4], so wa[0] is v[1]; back [3:0] takes w [0:3], so
// back[3] is w[0]. Every value is printed at time 1, after all have settled.
// Icarus Verilog 13.0 rejects the assignment of the net array w to back.

module inc8 (input logic [7:0] a, output logic [7:0] y);
  assign y = a + 8'd1;
endmodule

module test_net_array_elements_and_whole_array_assign;
  wire [7:0] w [0:3];
  wire [7:0] wa [0:3];
  logic [7:0] v [1:4];
  logic [7:0] back [3:0];

  assign w[0] = 8'h10;
  assign w[1] = w[0] + 8'h01;
  inc8 u_inc (.a(w[1]), .y(w[2]));
  assign w[3][7:4] = 4'ha;
  assign w[3][3:0] = w[2][3:0];
  assign wa = v;

  initial begin
    v[1] = 8'h11;
    v[2] = 8'h22;
    v[3] = 8'h33;
    v[4] = 8'h44;
    #1;
    $display("w: %h %h %h %h", w[0], w[1], w[2], w[3]);
    $display("wa from v: wa[0]=%h wa[1]=%h wa[2]=%h wa[3]=%h", wa[0], wa[1], wa[2], wa[3]);
    back = w;
    $display("back from w: back[3]=%h back[2]=%h back[1]=%h back[0]=%h",
             back[3], back[2], back[1], back[0]);
  end
endmodule
