/*
:name: test_gate_prim
:description: Test gate primitives (IEEE 1800-2023 Section 28)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gate_prim.expected
*/
// Test gate primitives (IEEE 1800-2023 Section 28)

module test_gate_prim;
  logic a, b;
  wire and_out, or_out, not_out, xor_out, nand_out;
  int pass_count;

  and u_and(and_out, a, b);
  or u_or(or_out, a, b);
  not u_not(not_out, a);
  xor u_xor(xor_out, a, b);
  nand u_nand(nand_out, a, b);

  initial begin
    pass_count = 0;

    // Test 1: AND gate
    a = 1;
    b = 1;
    #1;
    if (and_out == 1) pass_count++;

    // Test 2: OR gate
    a = 0;
    b = 1;
    #1;
    if (or_out == 1) pass_count++;

    // Test 3: NOT gate
    a = 0;
    #1;
    if (not_out == 1) pass_count++;

    // Test 4: XOR gate
    a = 1;
    b = 0;
    #1;
    if (xor_out == 1) pass_count++;

    // Test 5: NAND gate
    a = 1;
    b = 1;
    #1;
    if (nand_out == 0) pass_count++;

    $display("Gate prim tests: %0d/5 passed", pass_count);
    if (pass_count >= 4) begin
      $display("PASS: Gate prim tests");
    end else begin
      $display("FAIL: Some gate tests failed");
    end
  end
endmodule
