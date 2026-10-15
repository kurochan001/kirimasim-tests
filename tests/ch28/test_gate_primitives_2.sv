/*
:name: test_gate_primitives_2
:description: Gate Primitives Test
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3 28.4 28.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gate_primitives_2.expected
*/
// IEEE 1800-2023 §28 Gate Primitives Test
// Tests built-in combinational gate primitives

module test_gate_primitives_2;
  logic a, b, c;
  logic y_and, y_or, y_nand, y_nor, y_xor, y_xnor;
  logic y_not, y_buf;
  
  // IEEE 1800-2023 §28.3: Multi-input gates
  and  g1(y_and, a, b, c);
  or   g2(y_or, a, b, c);
  nand g3(y_nand, a, b);
  nor  g4(y_nor, a, b);
  xor  g5(y_xor, a, b);
  xnor g6(y_xnor, a, b);
  
  // IEEE 1800-2023 §28.4: buf and not gates
  not  g7(y_not, a);
  buf  g8(y_buf, a);
  
  int errors = 0;
  
  initial begin
    // Test case 1: All zeros
    a = 1'b0; b = 1'b0; c = 1'b0;
    #1;
    if (y_and !== 1'b0) begin $display("FAIL: and(0,0,0) = %b, expected 0", y_and); errors++; end
    if (y_or !== 1'b0) begin $display("FAIL: or(0,0,0) = %b, expected 0", y_or); errors++; end
    if (y_nand !== 1'b1) begin $display("FAIL: nand(0,0) = %b, expected 1", y_nand); errors++; end
    if (y_nor !== 1'b1) begin $display("FAIL: nor(0,0) = %b, expected 1", y_nor); errors++; end
    if (y_xor !== 1'b0) begin $display("FAIL: xor(0,0) = %b, expected 0", y_xor); errors++; end
    if (y_xnor !== 1'b1) begin $display("FAIL: xnor(0,0) = %b, expected 1", y_xnor); errors++; end
    if (y_not !== 1'b1) begin $display("FAIL: not(0) = %b, expected 1", y_not); errors++; end
    if (y_buf !== 1'b0) begin $display("FAIL: buf(0) = %b, expected 0", y_buf); errors++; end
    
    // Test case 2: All ones
    a = 1'b1; b = 1'b1; c = 1'b1;
    #1;
    if (y_and !== 1'b1) begin $display("FAIL: and(1,1,1) = %b, expected 1", y_and); errors++; end
    if (y_or !== 1'b1) begin $display("FAIL: or(1,1,1) = %b, expected 1", y_or); errors++; end
    if (y_nand !== 1'b0) begin $display("FAIL: nand(1,1) = %b, expected 0", y_nand); errors++; end
    if (y_nor !== 1'b0) begin $display("FAIL: nor(1,1) = %b, expected 0", y_nor); errors++; end
    if (y_xor !== 1'b0) begin $display("FAIL: xor(1,1) = %b, expected 0", y_xor); errors++; end
    if (y_xnor !== 1'b1) begin $display("FAIL: xnor(1,1) = %b, expected 1", y_xnor); errors++; end
    if (y_not !== 1'b0) begin $display("FAIL: not(1) = %b, expected 0", y_not); errors++; end
    if (y_buf !== 1'b1) begin $display("FAIL: buf(1) = %b, expected 1", y_buf); errors++; end
    
    // Test case 3: Mixed inputs
    a = 1'b1; b = 1'b0; c = 1'b1;
    #1;
    if (y_and !== 1'b0) begin $display("FAIL: and(1,0,1) = %b, expected 0", y_and); errors++; end
    if (y_or !== 1'b1) begin $display("FAIL: or(1,0,1) = %b, expected 1", y_or); errors++; end
    if (y_xor !== 1'b1) begin $display("FAIL: xor(1,0) = %b, expected 1", y_xor); errors++; end
    if (y_xnor !== 1'b0) begin $display("FAIL: xnor(1,0) = %b, expected 0", y_xnor); errors++; end
    
    if (errors == 0) begin
      $display("TEST PASSED");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
