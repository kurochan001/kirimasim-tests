/*
:name: test_assignment_deep
:description: assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 8.12 7.5 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_deep.expected
*/
// IEEE 1800-2023 §10 assignments

module tb;
  int pass_count = 0;
  int fail_count = 0;

  // Class definition at module scope (§8.3)
  class MyClass;
    int val;
    function new(int v);
      val = v;
    endfunction
  endclass

  typedef struct {
    int x;
    int y;
    string name;
  } point_t;

  typedef struct packed {
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
  } color_t;

  // Test 1: Struct assignment
  task automatic test_struct_assign;
    point_t p1, p2;
    p1.x = 10;
    p1.y = 20;
    p1.name = "origin";
    p2 = p1;
    if (p2.x == 10 && p2.y == 20 && p2.name == "origin") begin
      pass_count++;
      $display("PASS: struct assignment");
    end else begin
      fail_count++;
      $display("FAIL: struct assignment");
    end
  endtask

  // Test 2: Dynamic array assignment
  task automatic test_dynarray_assign;
    int a[], b[];
    a = new[3];
    a = '{1, 2, 3};
    b = a;
    b[0] = 99;
    if (a[0] == 1 && b[0] == 99) begin
      pass_count++;
      $display("PASS: dynamic array copy semantics");
    end else begin
      fail_count++;
      $display("FAIL: dynamic array copy semantics");
    end
  endtask

  // Test 3: Queue assignment
  task automatic test_queue_assign;
    int q1[$] = '{1, 2, 3};
    int q2[$];
    q2 = q1;
    q2.push_back(4);
    if (q1.size() == 3 && q2.size() == 4) begin
      pass_count++;
      $display("PASS: queue copy semantics");
    end else begin
      fail_count++;
      $display("FAIL: queue copy semantics");
    end
  endtask

  // Test 4: Type conversion assignment
  task automatic test_type_conversion;
    real r;
    int i;
    logic [31:0] bits;

    r = 3.14;
    i = int'(r);
    if (i == 3) begin
      pass_count++;
      $display("PASS: real to int conversion");
    end else begin
      fail_count++;
      $display("FAIL: real to int: got %0d", i);
    end

    bits = 32'hFFFF;
    i = signed'(bits);
    if (i == 65535) begin
      pass_count++;
      $display("PASS: unsigned to signed conversion");
    end else begin
      fail_count++;
      $display("FAIL: unsigned to signed: got %0d", i);
    end
  endtask

  // Test 5: Assign to class handle
  task automatic test_class_assign;
    MyClass a, b;
    a = new(42);
    b = a;
    b.val = 99;
    // Class handles are reference types
    if (a.val == 99) begin
      pass_count++;
      $display("PASS: class handle reference semantics");
    end else begin
      fail_count++;
      $display("FAIL: class reference: a.val=%0d", a.val);
    end
  endtask

  // Test 6: Assign pattern
  task automatic test_assign_pattern;
    color_t c;
    c = '{r: 8'hFF, g: 8'h00, b: 8'hAA};
    if (c.r === 8'hFF && c.g === 8'h00 && c.b === 8'hAA) begin
      pass_count++;
      $display("PASS: assignment pattern");
    end else begin
      fail_count++;
      $display("FAIL: assignment pattern");
    end
  endtask

  // Test 7: Multi-dimensional array element assignment
  task automatic test_multidim_assign;
    int matrix [0:2][0:2];
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        matrix[i][j] = i * 3 + j;

    if (matrix[1][2] == 5 && matrix[2][1] == 7) begin
      pass_count++;
      $display("PASS: multi-dimensional array assignment");
    end else begin
      fail_count++;
      $display("FAIL: multi-dimensional array assignment");
    end
  endtask

  // Test 8: Conditional assignment
  task automatic test_ternary_assign;
    logic [7:0] a = 0, b = 0;
    int sel = 1;
    if (sel) a = 8'hFF;
    else b = 8'hFF;
    if (a === 8'hFF && b === 8'h00) begin
      pass_count++;
      $display("PASS: conditional assignment");
    end else begin
      fail_count++;
      $display("FAIL: conditional assignment");
    end
  endtask

  initial begin
    test_struct_assign();
    test_dynarray_assign();
    test_queue_assign();
    test_type_conversion();
    test_class_assign();
    test_assign_pattern();
    test_multidim_assign();
    test_ternary_assign();

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
