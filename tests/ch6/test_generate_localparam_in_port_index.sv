/*
:name: test_generate_localparam_in_port_index
:description: A localparam of a loop generate block keeps its declared width when it is used in the index of a port connection (IEEE 1800-2023 Section 6.20.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 27.4 23.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_localparam_in_port_index.expected
*/
// IEEE 1800-2023 §6.20.2: a parameter declared with a type keeps that type and
// width. A localparam declared in a loop generate block (27.4) and used in the
// index of an expression connected to a port (23.3.3) is 33 or 64 bits wide
// there, so (OFFSET >> 32) is 1 and (BIG >> 62) is 2, and ~M of a 4-bit M is 0.

module generate_localparam_leaf(input logic [7:0] d, output logic [7:0] q);
  assign q = d;
endmodule

module test_generate_localparam_in_port_index;
  logic [7:0] arr[8];
  wire [7:0] q33[4], q64[4], qnot[4];
  for (genvar i = 0; i < 4; i++) begin : g
    localparam logic [32:0] OFFSET = 33'h1_0000_0001;
    localparam logic [63:0] BIG = 64'h8000_0000_0000_0002;
    localparam logic [3:0] M = 4'hF;
    generate_localparam_leaf u33 (.d(arr[(OFFSET >> 32) + i]), .q(q33[i]));  // A: 33 bits
    generate_localparam_leaf u64 (.d(arr[(BIG >> 62) + i]), .q(q64[i]));     // B: 64 bits
    generate_localparam_leaf unot (.d(arr[~M]), .q(qnot[i]));                // C: ~4'hF is 0
  end
  int errors = 0;

  task automatic check(string what, logic [7:0] got, logic [7:0] exp);
    if (got !== exp) begin
      $display("WRONG %s = %h, expected %h", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    for (int k = 0; k < 8; k++) arr[k] = 8'(20 + k);
    #2;
    for (int k = 0; k < 4; k++) begin
      check($sformatf("A q33[%0d]", k), q33[k], 8'(20 + k + 1));
      check($sformatf("B q64[%0d]", k), q64[k], 8'(20 + k + 2));
      check($sformatf("C qnot[%0d]", k), qnot[k], 8'(20));
    end
    if (errors == 0) begin
      $display("TEST PASSED: generate localparams keep their width in port indices");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
