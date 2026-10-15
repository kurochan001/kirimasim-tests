/*
:name: test_generate_corner
:description: Generate construct corner cases
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_corner.expected
*/
// IEEE 1800-2023 §27: Generate construct corner cases

module test_generate_corner;
  int test_count = 0;
  
  // Test 1: Generate with parameter edge values
  parameter int MIN_VAL = 0;
  parameter int MAX_VAL = 3;
  
  // Test 2: Nested generate loops
  genvar i, j;
  logic [7:0] matrix [0:3][0:3];
  
  generate
    for (i = 0; i <= MAX_VAL; i++) begin : outer_gen
      for (j = 0; j <= MAX_VAL; j++) begin : inner_gen
        assign matrix[i][j] = i * 4 + j;
      end
    end
  endgenerate
  
  // Test 3: Generate if-else
  parameter bit USE_FAST = 1;
  generate
    if (USE_FAST) begin : fast_path
      logic fast_signal;
      assign fast_signal = 1'b1;
    end else begin : slow_path
      logic slow_signal;
      assign slow_signal = 1'b0;
    end
  endgenerate
  
  // Test 4: Generate case
  parameter int MODE = 2;
  generate
    case (MODE)
      0: begin : mode_0
        localparam int MODE_VALUE = 0;
      end
      1: begin : mode_1
        localparam int MODE_VALUE = 1;
      end
      default: begin : mode_default
        localparam int MODE_VALUE = 99;
      end
    endcase
  endgenerate

  initial begin
    // The values come from continuous assignments; their order against this
    // initial block at time 0 is not defined (4.7), so wait first.
    #1;
    // Verify generate loops
    test_count++;
    assert(matrix[0][0] == 0) else $error("matrix[0][0] wrong");
    assert(matrix[1][2] == 6) else $error("matrix[1][2] wrong");
    assert(matrix[3][3] == 15) else $error("matrix[3][3] wrong");
    $display("Test %0d: Generate nested loops OK", test_count);

    // Verify generate if
    test_count++;
    assert(fast_path.fast_signal == 1'b1) else $error("fast_signal wrong");
    $display("Test %0d: Generate if-else OK", test_count);

    // Verify generate case
    test_count++;
    assert(mode_default.MODE_VALUE == 99) else $error("Mode value wrong");
    $display("Test %0d: Generate case OK", test_count);

    // Test matrix access patterns
    test_count++;
    for (int r = 0; r < 4; r++) begin
      for (int c = 0; c < 4; c++) begin
        assert(matrix[r][c] == r * 4 + c) else $error("Matrix value wrong at [%0d][%0d]", r, c);
      end
    end
    $display("Test %0d: Full matrix verification OK", test_count);
    
    $display("All %0d generate corner tests passed", test_count);
    $display("TEST PASSED");
    $finish;
  end
endmodule
