/*
:name: test_struct_member_access
:description: Test for struct member access (IEEE 1800-2023 §7.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 7.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_member_access.expected
*/
// Test for struct member access (IEEE 1800-2023 §7.2)
// Tests packed and unpacked struct member access

module test_struct_member_access;

  // Unpacked struct
  typedef struct {
    int x;
    int y;
    string name;
  } point_t;

  // Packed struct
  typedef struct packed {
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
    logic [7:0] a;
  } color_t;

  // Nested struct
  typedef struct {
    point_t origin;
    int width;
    int height;
  } rect_t;

  int pass_count = 0;
  int test_count = 0;

  initial begin
    point_t pt;
    color_t col;
    rect_t rect;
    logic [31:0] packed_val;
    int result;

    // Test 1: Unpacked struct member write and read
    test_count++;
    pt.x = 10;
    pt.y = 20;
    pt.name = "origin";
    if (pt.x == 10 && pt.y == 20) begin
      $display("PASS: pt.x=%0d, pt.y=%0d", pt.x, pt.y);
      pass_count++;
    end else begin
      $display("FAIL: Expected (10, 20), got (%0d, %0d)", pt.x, pt.y);
    end

    // Test 2: Unpacked struct string member
    test_count++;
    if (pt.name == "origin") begin
      $display("PASS: pt.name=%s", pt.name);
      pass_count++;
    end else begin
      $display("FAIL: Expected origin, got %s", pt.name);
    end

    // Test 3: Packed struct member write
    test_count++;
    col.r = 8'hFF;
    col.g = 8'h80;
    col.b = 8'h40;
    col.a = 8'h00;
    if (col.r == 8'hFF && col.g == 8'h80) begin
      $display("PASS: col.r=0x%02X, col.g=0x%02X", col.r, col.g);
      pass_count++;
    end else begin
      $display("FAIL: Packed struct write failed");
    end

    // Test 4: Packed struct as single value
    test_count++;
    packed_val = col;
    if (packed_val == 32'hFF804000) begin
      $display("PASS: Packed struct value=0x%08X", packed_val);
      pass_count++;
    end else begin
      // The first member of a packed struct is the most significant (7.2.1)
      $display("FAIL: Packed struct value=0x%08X", packed_val);
    end

    // Test 5: Nested struct member access
    test_count++;
    rect.origin.x = 100;
    rect.origin.y = 200;
    rect.width = 50;
    rect.height = 75;
    if (rect.origin.x == 100 && rect.origin.y == 200) begin
      $display("PASS: rect.origin.x=%0d, rect.origin.y=%0d", rect.origin.x, rect.origin.y);
      pass_count++;
    end else begin
      $display("FAIL: Nested struct access failed");
    end

    // Test 6: Nested struct width/height
    test_count++;
    if (rect.width == 50 && rect.height == 75) begin
      $display("PASS: rect.width=%0d, rect.height=%0d", rect.width, rect.height);
      pass_count++;
    end else begin
      $display("FAIL: Nested struct outer members failed");
    end

    // Test 7: Modify nested struct member via inner struct assign
    test_count++;
    begin
      point_t new_origin;
      new_origin.x = 110;
      new_origin.y = 210;
      new_origin.name = "modified";
      rect.origin = new_origin;
    end
    if (rect.origin.x == 110) begin
      $display("PASS: Modified rect.origin.x=%0d", rect.origin.x);
      pass_count++;
    end else begin
      $display("FAIL: Expected 110, got %0d", rect.origin.x);
    end

    // Test 8: Struct array
    test_count++;
    begin
      point_t points[3];
      points[0].x = 1;
      points[1].x = 2;
      points[2].x = 3;
      if (points[0].x == 1 && points[1].x == 2 && points[2].x == 3) begin
        $display("PASS: Struct array access works");
        pass_count++;
      end else begin
        $display("FAIL: Struct array access failed");
      end
    end

    // Test 9: Packed struct bit selection
    test_count++;
    col = 32'hAABBCCDD;
    if (col.r == 8'hAA) begin
      $display("PASS: col.r after assignment = 0x%02X", col.r);
      pass_count++;
    end else begin
      $display("FAIL: col.r = 0x%02X", col.r);
    end

    // Test 10: Struct member arithmetic
    test_count++;
    pt.x = 5;
    pt.y = 10;
    result = pt.x + pt.y;
    if (result == 15) begin
      $display("PASS: pt.x + pt.y = %0d", result);
      pass_count++;
    end else begin
      $display("FAIL: Expected 15, got %0d", result);
    end

    // Summary
    $display("");
    $display("=== Struct Member Access Test Summary ===");
    $display("Tests: %0d, Passed: %0d", test_count, pass_count);
    if (pass_count == test_count) begin
      $display("PASS: All struct member access tests passed");
    end else begin
      $display("FAIL: Some struct member access tests failed");
    end

    $finish;
  end

endmodule
