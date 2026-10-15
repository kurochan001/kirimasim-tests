/*
:name: test_multidim_unpacked
:description: Unpacked arrays
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2 7.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multidim_unpacked.expected
*/
// IEEE 1800-2023 Section 7.4 - Unpacked arrays
// Test: Multi-dimensional unpacked arrays

module test_multidim_unpacked;
  int matrix [3][4];  // 3x4 matrix
  int cube [2][3][4];  // 2x3x4 cube

  initial begin
    // Initialize 2D array
    for (int i = 0; i < 3; i++) begin
      for (int j = 0; j < 4; j++) begin
        matrix[i][j] = i * 10 + j;
      end
    end

    // Verify 2D array
    if (matrix[0][0] != 0) $fatal(1, "FAIL: matrix[0][0]");
    if (matrix[0][3] != 3) $fatal(1, "FAIL: matrix[0][3]");
    if (matrix[2][1] != 21) $fatal(1, "FAIL: matrix[2][1]");
    if (matrix[2][3] != 23) $fatal(1, "FAIL: matrix[2][3]");

    // Initialize 3D array
    for (int i = 0; i < 2; i++) begin
      for (int j = 0; j < 3; j++) begin
        for (int k = 0; k < 4; k++) begin
          cube[i][j][k] = i * 100 + j * 10 + k;
        end
      end
    end

    // Verify 3D array
    $display("cube[0][0][0] = %0d (expected 0)", cube[0][0][0]);
    if (cube[0][0][0] != 0) $fatal(1, "FAIL: cube[0][0][0]");
    $display("cube[0][2][3] = %0d (expected 23)", cube[0][2][3]);
    if (cube[0][2][3] != 23) $fatal(1, "FAIL: cube[0][2][3]");
    $display("cube[1][0][0] = %0d (expected 100)", cube[1][0][0]);
    if (cube[1][0][0] != 100) $fatal(1, "FAIL: cube[1][0][0]");
    $display("cube[1][2][3] = %0d (expected 123)", cube[1][2][3]);
    if (cube[1][2][3] != 123) $fatal(1, "FAIL: cube[1][2][3]");

    $display("PASS: Multi-dimensional unpacked arrays");
    $finish(0);
  end
endmodule
