/*
:name: test_virt_method
:description: Test virtual methods (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.14
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virt_method.expected
*/
// Test virtual methods (IEEE 1800-2023 Section 8.20)

class Shape;
  virtual function int area();
    return 0;
  endfunction
endclass

class Rectangle extends Shape;
  int width, height;

  function new(int w, int h);
    width = w;
    height = h;
  endfunction

  function int area();
    return width * height;
  endfunction
endclass

class Square extends Rectangle;
  function new(int s);
    super.new(s, s);
  endfunction
endclass

module test_virt_method;
  Shape s;
  Rectangle r;
  Square sq;
  int pass_count;

  initial begin
    pass_count = 0;

    // Test 1: Rectangle area
    r = new(4, 5);
    if (r.area() == 20) pass_count++;

    // Test 2: Square area
    sq = new(6);
    if (sq.area() == 36) pass_count++;

    // Test 3: Polymorphic call via base
    s = r;
    if (s.area() == 20) pass_count++;

    // Test 4: Another polymorphic call
    s = sq;
    if (s.area() == 36) pass_count++;

    $display("Virt method tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Virt method tests");
    end else begin
      $display("FAIL: Some virt method tests failed");
    end
  end
endmodule
