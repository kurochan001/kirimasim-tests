/*
:name: test_class_virtual_2
:description: Test: virtual class (abstract), virtual method, polymorphism via base handle
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual_2.expected
*/
// Test: virtual class (abstract), virtual method, polymorphism via base handle
module test_class_virtual_2;

  virtual class Shape;
    int color;

    function new(int c);
      color = c;
    endfunction

    pure virtual function int area();

    virtual function string kind();
      return "shape";
    endfunction
  endclass

  class Rectangle extends Shape;
    int w, h;

    function new(int w_val, int h_val, int c);
      super.new(c);
      w = w_val;
      h = h_val;
    endfunction

    function int area();
      return w * h;
    endfunction

    function string kind();
      return "rectangle";
    endfunction
  endclass

  class Circle extends Shape;
    int radius;

    function new(int r, int c);
      super.new(c);
      radius = r;
    endfunction

    function int area();
      // Approximate: pi * r^2 ~ 3 * r^2
      return 3 * radius * radius;
    endfunction

    function string kind();
      return "circle";
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Shape s;
    Rectangle r;
    Circle ci;

    r = new(5, 3, 1);
    ci = new(4, 2);

    // Check 1: rectangle area
    if (r.area() == 15) begin pass_cnt++; $display("PASS: rect area == 15"); end
    else begin fail_cnt++; $display("FAIL: rect area = %0d", r.area()); end

    // Check 2: circle area (3 * 16 = 48)
    if (ci.area() == 48) begin pass_cnt++; $display("PASS: circle area == 48"); end
    else begin fail_cnt++; $display("FAIL: circle area = %0d", ci.area()); end

    // Check 3: polymorphism: base handle calls derived area
    s = r;
    if (s.area() == 15) begin pass_cnt++; $display("PASS: polymorphic rect area"); end
    else begin fail_cnt++; $display("FAIL: polymorphic rect area = %0d", s.area()); end

    // Check 4: polymorphism: reassign base handle to circle
    s = ci;
    if (s.area() == 48) begin pass_cnt++; $display("PASS: polymorphic circle area"); end
    else begin fail_cnt++; $display("FAIL: polymorphic circle area = %0d", s.area()); end

    // Check 5: virtual kind() override
    s = r;
    if (s.kind() == "rectangle") begin pass_cnt++; $display("PASS: polymorphic kind == rectangle"); end
    else begin fail_cnt++; $display("FAIL: kind = %s", s.kind()); end

    // Check 6: color inherited via super.new
    if (r.color == 1 && ci.color == 2) begin pass_cnt++; $display("PASS: color inheritance"); end
    else begin fail_cnt++; $display("FAIL: colors r=%0d ci=%0d", r.color, ci.color); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
