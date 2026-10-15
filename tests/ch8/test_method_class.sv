/*
:name: test_method_class
:description: Class methods test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 8.7 13.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_method_class.expected
*/
// Class methods test
module test_method_class;

  class Counter;
    int value;
    string name;

    // Constructor
    function new(string n, int initial_val = 0);
      name = n;
      value = initial_val;
    endfunction

    // Getter method
    function int get_value();
      return value;
    endfunction

    // Setter method
    function void set_value(int v);
      value = v;
    endfunction

    // Increment method
    function void increment(int amount = 1);
      value = value + amount;
    endfunction

    // Method returning string
    function string to_string();
      string result;
      $sformat(result, "%s: %0d", name, value);
      return result;
    endfunction

    // Method calling other method
    function int get_doubled();
      return get_value() * 2;
    endfunction
  endclass

  class Calculator;
    // Method with multiple parameters
    function int add(int a, int b);
      return a + b;
    endfunction

    function int multiply(int a, int b);
      return a * b;
    endfunction

    // Method with local variables
    function int compute_expression(int a, int b, int c);
      int temp1, temp2;
      temp1 = add(a, b);
      temp2 = multiply(temp1, c);
      return temp2;
    endfunction
  endclass

  initial begin
    Counter cnt;
    Calculator calc;
    int result;
    string str_result;
    int pass_count;

    pass_count = 0;

    // Test 1: Constructor and getter
    cnt = new("test_counter", 10);
    result = cnt.get_value();
    if (result == 10) begin
      $display("Test 1 PASS: Counter created with value %0d", result);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: value = %0d, expected 10", result);
    end

    // Test 2: Setter method
    cnt.set_value(50);
    result = cnt.get_value();
    if (result == 50) begin
      $display("Test 2 PASS: set_value(50) -> value = %0d", result);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: value = %0d, expected 50", result);
    end

    // Test 3: Increment method with default parameter
    cnt.increment();
    cnt.increment(5);
    result = cnt.get_value();
    if (result == 56) begin
      $display("Test 3 PASS: increment() and increment(5) -> value = %0d", result);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: value = %0d, expected 56", result);
    end

    // Test 4: Method calling another method
    result = cnt.get_doubled();
    if (result == 112) begin
      $display("Test 4 PASS: get_doubled() = %0d", result);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: get_doubled() = %0d, expected 112", result);
    end

    // Test 5: Calculator class methods
    calc = new();
    result = calc.compute_expression(2, 3, 4);  // (2+3)*4 = 20
    if (result == 20) begin
      $display("Test 5 PASS: compute_expression(2,3,4) = %0d", result);
      pass_count++;
    end else begin
      $display("Test 5 FAIL: result = %0d, expected 20", result);
    end

    if (pass_count == 5)
      $display("PASS: All class method tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
