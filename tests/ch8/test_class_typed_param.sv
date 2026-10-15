/*
:name: test_class_typed_param
:description: Test: Type parameter in class
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 8.25.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_typed_param.expected
*/
// Test: Type parameter in class
// IEEE 1800-2023 Section 8.25.1 - Type parameters

module test_class_typed_param;

  // Generic container with type parameter
  class Container #(type T = int);
    T value;

    function new(T v);
      value = v;
    endfunction

    function T get();
      return value;
    endfunction

    function void set(T v);
      value = v;
    endfunction
  endclass

  // Generic pair with two type parameters
  class Pair #(type T1 = int, type T2 = int);
    T1 first;
    T2 second;

    function new(T1 f, T2 s);
      first = f;
      second = s;
    endfunction

    function T1 get_first();
      return first;
    endfunction

    function T2 get_second();
      return second;
    endfunction

  endclass

  // Generic queue wrapper
  class TypedQueue #(type T = int);
    T items[$];

    function new();
    endfunction

    function void enqueue(T item);
      items.push_back(item);
    endfunction

    function T dequeue();
      T result = items[0];
      items.delete(0);
      return result;
    endfunction

    function int size();
      return items.size();
    endfunction

    function bit is_empty();
      return (items.size() == 0);
    endfunction
  endclass

  // Type parameter with class type
  class Wrapper #(type T = int);
    T wrapped;

    function new(T w);
      wrapped = w;
    endfunction

    function T unwrap();
      return wrapped;
    endfunction
  endclass

  class SimpleClass;
    int value;

    function new(int v);
      value = v;
    endfunction
  endclass

  // Mix of type and value parameters
  class Array #(type T = int, int SIZE = 4);
    T data[SIZE];

    function new();
    endfunction

    function void set(int idx, T val);
      if (idx < SIZE)
        data[idx] = val;
    endfunction

    function T get(int idx);
      if (idx < SIZE)
        return data[idx];
      else begin
        T default_val;
        return default_val;
      end
    endfunction

    function int length();
      return SIZE;
    endfunction
  endclass

  initial begin
    Container #(int) int_container;
    Container #(string) str_container;
    Pair #(int, string) pair;
    TypedQueue #(int) int_queue;
    Wrapper #(SimpleClass) class_wrapper;
    SimpleClass sc;
    Array #(int, 8) int_array;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Container with int type
    int_container = new(42);
    if (int_container.get() == 42) begin
      int_container.set(100);
      if (int_container.get() == 100) begin
        $display("PASS: Test 1 - Container<int> works");
        pass_count++;
      end else begin
        $display("FAIL: Test 1 - Container set failed");
        fail_count++;
      end
    end else begin
      $display("FAIL: Test 1 - Container<int> failed");
      fail_count++;
    end

    // Test 2: Container with string type
    str_container = new("hello");
    if (str_container.get() == "hello") begin
      str_container.set("world");
      if (str_container.get() == "world") begin
        $display("PASS: Test 2 - Container<string> works");
        pass_count++;
      end else begin
        $display("FAIL: Test 2 - Container<string> set failed");
        fail_count++;
      end
    end else begin
      $display("FAIL: Test 2 - Container<string> failed");
      fail_count++;
    end

    // Test 3: Pair with mixed types
    pair = new(123, "abc");
    if (pair.get_first() == 123 && pair.get_second() == "abc") begin
      $display("PASS: Test 3 - Pair<int, string> works");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Pair failed");
      fail_count++;
    end

    // Test 4: TypedQueue with int
    int_queue = new();
    int_queue.enqueue(10);
    int_queue.enqueue(20);
    int_queue.enqueue(30);
    if (int_queue.size() == 3 && int_queue.dequeue() == 10 && int_queue.dequeue() == 20) begin
      $display("PASS: Test 4 - TypedQueue<int> works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - TypedQueue failed");
      fail_count++;
    end

    // Test 5: Mixed type and value parameters
    int_array = new();
    int_array.set(0, 100);
    int_array.set(7, 700);
    if (int_array.length() == 8 && int_array.get(0) == 100 && int_array.get(7) == 700) begin
      $display("PASS: Test 5 - Array<int, 8> with mixed parameters works");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Mixed parameters failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All type parameter tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
