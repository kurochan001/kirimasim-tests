/*
:name: test_gate_primitives
:description: Gate and switch declaration
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3 28.4 28.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_gate_primitives.expected
*/
// IEEE 1800-2023 §28.3: Gate and switch declaration
// Tests basic gate primitives (and, or, not, nand, nor, xor)
// Verifies gate truth table evaluation for all input combinations

module test_gate_primitives;
  logic a, b, out_and, out_or, out_not, out_nand, out_nor, out_xor;

  // Gate instantiations
  and g1(out_and, a, b);
  or  g2(out_or, a, b);
  not g3(out_not, a);
  nand g4(out_nand, a, b);
  nor g5(out_nor, a, b);
  xor g6(out_xor, a, b);

  initial begin
    // Test case 1: a=0, b=0
    a = 0; b = 0; #1;
    assert(out_and == 0 && out_or == 0 && out_not == 1 &&
           out_nand == 1 && out_nor == 1 && out_xor == 0)
      else $fatal(1, "Gate logic failed for a=0, b=0");

    // Test case 2: a=0, b=1
    a = 0; b = 1; #1;
    assert(out_and == 0 && out_or == 1 && out_not == 1 &&
           out_nand == 1 && out_nor == 0 && out_xor == 1)
      else $fatal(1, "Gate logic failed for a=0, b=1");

    // Test case 3: a=1, b=0
    a = 1; b = 0; #1;
    assert(out_and == 0 && out_or == 1 && out_not == 0 &&
           out_nand == 1 && out_nor == 0 && out_xor == 1)
      else $fatal(1, "Gate logic failed for a=1, b=0");

    // Test case 4: a=1, b=1
    a = 1; b = 1; #1;
    assert(out_and == 1 && out_or == 1 && out_not == 0 &&
           out_nand == 0 && out_nor == 0 && out_xor == 0)
      else $fatal(1, "Gate logic failed for a=1, b=1");

    $display("PASS: Gate-level primitives test completed");
    $finish;
  end
endmodule
