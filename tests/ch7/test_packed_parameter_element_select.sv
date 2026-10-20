/*
:name: test_packed_parameter_element_select
:description: Elements of a parameter or localparam with packed dimensions are selected by their declared indices, ascending or descending (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5 6.20.1 7.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_parameter_element_select.expected
*/
// IEEE 1800-2023 §6.20.1: a parameter can have packed dimensions, as a
// variable can (7.4.1). §7.4.5: an element is selected by its declared index:
// for [0:1][7:0] index 0 is the leftmost, most significant element, for
// [1:0][7:0] index 1 is, also with a variable index.

module test_packed_parameter_element_select;
  parameter [0:1][7:0] QA = {8'd3, 8'd4};
  parameter [1:0][7:0] QD = {8'd3, 8'd4};
  localparam [0:2][3:0] LA = {4'd1, 4'd2, 4'd5};
  int i = 1;

  initial begin
    $display("QA[0]=%0d QA[1]=%0d QA[i]=%0d", QA[0], QA[1], QA[i]);
    $display("QD[1]=%0d QD[0]=%0d", QD[1], QD[0]);
    $display("LA[0]=%0d LA[1]=%0d LA[2]=%0d", LA[0], LA[1], LA[2]);
  end
endmodule
