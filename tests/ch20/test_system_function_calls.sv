/*
:name: test_system_function_calls
:description: Calls to math, bit, conversion, query, string format and time system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.8.2 20.9 20.5 20.6.2 20.7 21.3.3 20.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_system_function_calls.expected
*/
// IEEE 1800-2023 §20 system functions

module tb;
  int pass_count = 0;
  int fail_count = 0;

  // Test 1: Math functions
  task automatic test_math_functions;
    real r;

    // $clog2
    if ($clog2(8) == 3) begin
      pass_count++;
      $display("PASS: $clog2(8)");
    end else begin
      fail_count++;
      $display("FAIL: $clog2(8): got %0d", $clog2(8));
    end

    // $clog2 edge case
    if ($clog2(1) == 0) begin
      pass_count++;
      $display("PASS: $clog2(1)");
    end else begin
      fail_count++;
      $display("FAIL: $clog2(1): got %0d", $clog2(1));
    end

    // $ln
    r = $ln(2.718281828);
    if (r > 0.99 && r < 1.01) begin
      pass_count++;
      $display("PASS: $ln");
    end else begin
      fail_count++;
      $display("FAIL: $ln: got %f", r);
    end

    // $sqrt
    r = $sqrt(144.0);
    if (r > 11.99 && r < 12.01) begin
      pass_count++;
      $display("PASS: $sqrt");
    end else begin
      fail_count++;
      $display("FAIL: $sqrt: got %f", r);
    end

    // $pow
    r = $pow(2.0, 10.0);
    if (r > 1023.9 && r < 1024.1) begin
      pass_count++;
      $display("PASS: $pow");
    end else begin
      fail_count++;
      $display("FAIL: $pow: got %f", r);
    end

    // $floor / $ceil
    if ($floor(3.7) == 3.0) begin
      pass_count++;
      $display("PASS: $floor");
    end else begin
      fail_count++;
      $display("FAIL: $floor");
    end

    if ($ceil(3.2) == 4.0) begin
      pass_count++;
      $display("PASS: $ceil");
    end else begin
      fail_count++;
      $display("FAIL: $ceil");
    end
  endtask

  // Test 2: Bit counting functions
  task automatic test_bit_functions;
    logic [7:0] val;

    // $countones
    val = 8'b10101010;
    if ($countones(val) == 4) begin
      pass_count++;
      $display("PASS: $countones");
    end else begin
      fail_count++;
      $display("FAIL: $countones: got %0d", $countones(val));
    end

    // $onehot
    val = 8'b00001000;
    if ($onehot(val) == 1) begin
      pass_count++;
      $display("PASS: $onehot true");
    end else begin
      fail_count++;
      $display("FAIL: $onehot true");
    end

    val = 8'b00001010;
    if ($onehot(val) == 0) begin
      pass_count++;
      $display("PASS: $onehot false");
    end else begin
      fail_count++;
      $display("FAIL: $onehot false");
    end

    // $onehot0
    val = 8'b00000000;
    if ($onehot0(val) == 1) begin
      pass_count++;
      $display("PASS: $onehot0 zero");
    end else begin
      fail_count++;
      $display("FAIL: $onehot0 zero");
    end

    // $isunknown
    val = 8'b0000x000;
    if ($isunknown(val) == 1) begin
      pass_count++;
      $display("PASS: $isunknown with x");
    end else begin
      fail_count++;
      $display("FAIL: $isunknown with x");
    end
  endtask

  // Test 3: Conversion functions
  task automatic test_conversion;
    int signed_val;
    logic [31:0] unsigned_val;

    // $signed / $unsigned
    unsigned_val = 32'hFFFFFFFF;
    signed_val = $signed(unsigned_val);
    if (signed_val == -1) begin
      pass_count++;
      $display("PASS: $signed");
    end else begin
      fail_count++;
      $display("FAIL: $signed: got %0d", signed_val);
    end

    // $itor / $rtoi
    begin
      real r;
      int i;
      r = $itor(42);
      i = $rtoi(3.14);
      if (r == 42.0 && i == 3) begin
        pass_count++;
        $display("PASS: $itor/$rtoi");
      end else begin
        fail_count++;
        $display("FAIL: $itor/$rtoi");
      end
    end

    // $bits
    if ($bits(unsigned_val) == 32) begin
      pass_count++;
      $display("PASS: $bits");
    end else begin
      fail_count++;
      $display("FAIL: $bits: got %0d", $bits(unsigned_val));
    end
  endtask

  // Test 4: Type query functions
  task automatic test_type_query;
    logic [15:0] vec;

    // $left / $right
    if ($left(vec) == 15 && $right(vec) == 0) begin
      pass_count++;
      $display("PASS: $left/$right");
    end else begin
      fail_count++;
      $display("FAIL: $left/$right");
    end

    // $size on packed type
    if ($size(vec) == 16) begin
      pass_count++;
      $display("PASS: $size on packed");
    end else begin
      fail_count++;
      $display("FAIL: $size on packed: got %0d", $size(vec));
    end
  endtask

  // Test 5: String formatting
  task automatic test_sformat;
    string s;
    $sformat(s, "Value = %0d, Hex = %h", 42, 32'hDEAD);
    if (s == "Value = 42, Hex = 0000dead") begin
      pass_count++;
      $display("PASS: $sformat");
    end else begin
      fail_count++;
      $display("FAIL: $sformat: got '%s'", s);
    end
  endtask

  // Test 6: Time functions
  task automatic test_time_functions;
    realtime t;
    t = $realtime;
    if (t >= 0.0) begin
      pass_count++;
      $display("PASS: $realtime");
    end else begin
      fail_count++;
      $display("FAIL: $realtime");
    end
  endtask

  initial begin
    test_math_functions();
    test_bit_functions();
    test_conversion();
    test_type_query();
    test_sformat();
    test_time_functions();

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
