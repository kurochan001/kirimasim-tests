/*
:name: test_param_class_multiple_params
:description: Parameterized Classes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_multiple_params.expected
*/
// IEEE 1800-2023 Section 8.25 - Parameterized Classes
// Test: Multiple parameters with different types

module test_param_class_multiple_params;
  // Parameterized class with type and value parameters
  class Matrix #(type T = int, int ROWS = 2, int COLS = 2);
    T data[ROWS][COLS];

    function new();
      foreach (data[i, j]) data[i][j] = T'(0);
    endfunction

    function void set(int row, int col, T value);
      if (row < ROWS && col < COLS) data[row][col] = value;
    endfunction

    function T get(int row, int col);
      if (row < ROWS && col < COLS) return data[row][col];
      return T'(0);
    endfunction

    function int rows();
      return ROWS;
    endfunction

    function int cols();
      return COLS;
    endfunction
  endclass

  initial begin
    static Matrix#(int, 3, 3) mat_int = new();
    static Matrix#(real, 2, 4) mat_real = new();

    // Test integer matrix
    mat_int.set(0, 0, 10);
    mat_int.set(1, 1, 20);
    mat_int.set(2, 2, 30);

    if (mat_int.rows() != 3) $fatal(1, "FAIL: mat_int rows");
    if (mat_int.cols() != 3) $fatal(1, "FAIL: mat_int cols");
    if (mat_int.get(0, 0) != 10) $fatal(1, "FAIL: mat_int get(0,0)");
    if (mat_int.get(1, 1) != 20) $fatal(1, "FAIL: mat_int get(1,1)");
    if (mat_int.get(2, 2) != 30) $fatal(1, "FAIL: mat_int get(2,2)");

    // Test real matrix
    mat_real.set(0, 0, 1.5);
    mat_real.set(1, 3, 2.5);

    if (mat_real.rows() != 2) $fatal(1, "FAIL: mat_real rows");
    if (mat_real.cols() != 4) $fatal(1, "FAIL: mat_real cols");
    if (mat_real.get(0, 0) != 1.5) $fatal(1, "FAIL: mat_real get(0,0)");
    if (mat_real.get(1, 3) != 2.5) $fatal(1, "FAIL: mat_real get(1,3)");

    $display("PASS: Parameterized class multiple parameters");
    $finish(0);
  end
endmodule
