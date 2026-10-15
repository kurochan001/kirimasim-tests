/*
:name: test_class_this
:description: Test: this keyword usage
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.11 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_this.expected
*/
// Test: this keyword usage
// IEEE 1800-2023 Section 8.11 - this

module test_class_this;

  // Class using this to disambiguate
  class Point;
    int x, y;

    function new(int x, int y);
      this.x = x;  // this.x is member, x is parameter
      this.y = y;
    endfunction

    function void set(int x, int y);
      this.x = x;
      this.y = y;
    endfunction

    function int get_x();
      return this.x;  // Explicit this for clarity
    endfunction

    function int get_y();
      return this.y;
    endfunction

    // Return this for method chaining
    function Point move(int dx, int dy);
      this.x += dx;
      this.y += dy;
      return this;
    endfunction

    // Compare with another point
    function bit equals(Point other);
      return (this.x == other.x && this.y == other.y);
    endfunction

    // Copy this object's values to another
    function void copy_to(Point dest);
      dest.x = this.x;
      dest.y = this.y;
    endfunction
  endclass

  // Class that passes this to other methods
  class Node;
    int data;
    Node next;

    function new(int d);
      data = d;
      next = null;
    endfunction

    // Append and return this for chaining
    function Node append(Node n);
      this.next = n;
      return this;
    endfunction

    // Check if this is same object
    function bit is_same(Node other);
      return (this == other);
    endfunction
  endclass

  // Builder pattern using this
  class StringBuilder;
    string content;

    function new();
      content = "";
    endfunction

    function StringBuilder append_str(string s);
      this.content = {this.content, s};
      return this;
    endfunction

    function StringBuilder append_int(int i);
      this.content = {this.content, $sformatf("%0d", i)};
      return this;
    endfunction

    function string build();
      return this.content;
    endfunction
  endclass

  initial begin
    Point p1, p2, p3;
    Node n1, n2;
    StringBuilder sb;
    string result;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: this in constructor to disambiguate
    p1 = new(10, 20);
    if (p1.x == 10 && p1.y == 20) begin
      $display("PASS: Test 1 - this.member = parameter works");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Constructor disambiguation failed");
      fail_count++;
    end

    // Test 2: Explicit this for member access
    if (p1.get_x() == 10 && p1.get_y() == 20) begin
      $display("PASS: Test 2 - this.member in getter works");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Getter with this failed");
      fail_count++;
    end

    // Test 3: Return this for method chaining
    p2 = new(0, 0);
    p3 = p2.move(5, 5).move(3, 3);
    if (p2.x == 8 && p2.y == 8 && p3 == p2) begin
      $display("PASS: Test 3 - Return this enables method chaining");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Method chaining failed");
      fail_count++;
    end

    // Test 4: this vs other comparison
    p1.set(5, 5);
    p2.set(8, 8);
    p3 = new(8, 8);
    if (!p1.equals(p2) && p2.equals(p3)) begin
      $display("PASS: Test 4 - this.member vs other.member comparison");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Object comparison failed");
      fail_count++;
    end

    // Test 5: Builder pattern with this chaining
    sb = new();
    result = sb.append_str("Value: ").append_int(42).append_str("!").build();
    if (result == "Value: 42!") begin
      $display("PASS: Test 5 - Builder pattern with this chaining");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Builder pattern failed: %s", result);
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All this keyword tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
