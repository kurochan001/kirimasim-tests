/*
:name: test_class_extern
:description: Test: Extern method declaration
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.24 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_extern.expected
*/
// Test: Extern method declaration
// IEEE 1800-2023 Section 8.24 - Out-of-block declarations

module test_class_extern;

  // Class with extern method declarations
  class Calculator;
    int value;

    function new(int v);
      value = v;
    endfunction

    // Extern function declarations
    extern function int add(int x);
    extern function int subtract(int x);
    extern function int multiply(int x);
    extern function void reset();
    extern function string to_string();
  endclass

  // Out-of-block function definitions
  function int Calculator::add(int x);
    value += x;
    return value;
  endfunction

  function int Calculator::subtract(int x);
    value -= x;
    return value;
  endfunction

  function int Calculator::multiply(int x);
    value *= x;
    return value;
  endfunction

  function void Calculator::reset();
    value = 0;
  endfunction

  function string Calculator::to_string();
    return $sformatf("Value = %0d", value);
  endfunction

  // Class with extern virtual methods
  class Shape;
    extern virtual function int area();
    extern virtual function string name();
  endclass

  function int Shape::area();
    return 0;
  endfunction

  function string Shape::name();
    return "Shape";
  endfunction

  // Derived class overriding extern virtual
  class Rectangle extends Shape;
    int width, height;

    function new(int w, int h);
      width = w;
      height = h;
    endfunction

    extern virtual function int area();
    extern virtual function string name();
  endclass

  function int Rectangle::area();
    return width * height;
  endfunction

  function string Rectangle::name();
    return $sformatf("Rectangle(%0d x %0d)", width, height);
  endfunction

  // Class with extern task
  class AsyncProcessor;
    int result;

    function new();
      result = 0;
    endfunction

    extern task process(int data);
  endclass

  task AsyncProcessor::process(int data);
    result = data * 2;
  endtask

  initial begin
    Calculator calc;
    Shape s;
    Rectangle r;
    AsyncProcessor ap;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Basic extern function
    calc = new(10);
    if (calc.add(5) == 15) begin
      $display("PASS: Test 1 - Extern add() function works");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Extern add() failed");
      fail_count++;
    end

    // Test 2: Multiple extern functions
    calc.reset();
    calc.add(10);
    calc.multiply(3);
    calc.subtract(5);
    if (calc.value == 25) begin
      $display("PASS: Test 2 - Multiple extern functions work together");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Multiple extern failed: %0d", calc.value);
      fail_count++;
    end

    // Test 3: Extern function returning string
    calc.reset();
    calc.add(42);
    if (calc.to_string() == "Value = 42") begin
      $display("PASS: Test 3 - Extern to_string() returns correct string");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - to_string() wrong: %s", calc.to_string());
      fail_count++;
    end

    // Test 4: Extern virtual method override
    r = new(5, 3);
    s = r;  // Polymorphic reference
    if (s.area() == 15 && s.name() == "Rectangle(5 x 3)") begin
      $display("PASS: Test 4 - Extern virtual method override works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Extern virtual override failed");
      fail_count++;
    end

    // Test 5: Extern task
    ap = new();
    ap.process(21);
    if (ap.result == 42) begin
      $display("PASS: Test 5 - Extern task works");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Extern task failed: %0d", ap.result);
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All extern method tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
