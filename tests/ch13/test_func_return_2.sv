/*
:name: test_func_return_2
:description: Function return types test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_return_2.expected
*/
// Function return types test
module test_func_return;

  // Integer return type
  function int return_int();
    return -100;
  endfunction

  // Unsigned return type
  function bit [15:0] return_unsigned();
    return 16'hFFFF;
  endfunction

  // Real return type
  function real return_real();
    return 3.14159;
  endfunction

  // Logic vector return type
  function logic [31:0] return_logic();
    return 32'hCAFEBABE;
  endfunction

  // Shortint return type
  function shortint return_shortint();
    return -32768;
  endfunction

  // Byte return type
  function byte return_byte();
    return 8'sh80; // -128 in signed byte
  endfunction

  // String return type
  function string return_string();
    return "Hello";
  endfunction

  // Enum return type
  typedef enum {RED, GREEN, BLUE} color_t;
  function color_t return_enum();
    return GREEN;
  endfunction

  initial begin
    int i_val;
    bit [15:0] u_val;
    real r_val;
    logic [31:0] l_val;
    shortint si_val;
    byte b_val;
    string s_val;
    color_t c_val;
    int pass_count;

    pass_count = 0;

    // Test 1: Integer return
    i_val = return_int();
    if (i_val == -100) begin
      $display("Test 1 PASS: return_int() = %0d", i_val);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: return_int() = %0d, expected -100", i_val);
    end

    // Test 2: Unsigned return
    u_val = return_unsigned();
    if (u_val == 16'hFFFF) begin
      $display("Test 2 PASS: return_unsigned() = 0x%04h", u_val);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: return_unsigned() = 0x%04h, expected 0xFFFF", u_val);
    end

    // Test 3: Real return
    r_val = return_real();
    if (r_val > 3.14 && r_val < 3.15) begin
      $display("Test 3 PASS: return_real() = %f", r_val);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: return_real() = %f, expected ~3.14159", r_val);
    end

    // Test 4: Logic vector return
    l_val = return_logic();
    if (l_val == 32'hCAFEBABE) begin
      $display("Test 4 PASS: return_logic() = 0x%08h", l_val);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: return_logic() = 0x%08h, expected 0xCAFEBABE", l_val);
    end

    // Test 5: String return
    s_val = return_string();
    if (s_val == "Hello") begin
      $display("Test 5 PASS: return_string() = %s", s_val);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: return_string() = %s, expected Hello", s_val);
    end

    if (pass_count == 5)
      $display("PASS: All function return type tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
