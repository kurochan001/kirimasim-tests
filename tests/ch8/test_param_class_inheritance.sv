/*
:name: test_param_class_inheritance
:description: Parameterized Classes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 8.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_inheritance.expected
*/
// IEEE 1800-2023 Section 8.25 - Parameterized Classes
// Test: Parameterized class inheritance

module test_param_class_inheritance;
  // Base parameterized class
  class Container #(type T = int);
    T data[$];

    function void add(T item);
      data.push_back(item);
    endfunction

    function int size();
      return data.size();
    endfunction

    function T get(int index);
      if (index < data.size()) return data[index];
      return T'(0);
    endfunction
  endclass

  // Derived parameterized class
  class SortedContainer #(type T = int) extends Container#(T);
    function void add(T item);
      // Insert in sorted order (simple insertion sort)
      int pos = 0;
      for (int i = 0; i < data.size(); i++) begin
        if (item > data[i]) pos = i + 1;
      end
      if (pos >= data.size()) data.push_back(item);
      else data.insert(pos, item);
    endfunction

    function T min();
      if (data.size() > 0) return data[0];
      return T'(0);
    endfunction

    function T max();
      if (data.size() > 0) return data[$];
      return T'(0);
    endfunction
  endclass

  initial begin
    static SortedContainer#(int) sorted = new();

    // Add items in random order
    sorted.add(30);
    sorted.add(10);
    sorted.add(50);
    sorted.add(20);
    sorted.add(40);

    if (sorted.size() != 5) $fatal(1, "FAIL: sorted size");

    // Verify sorted order
    if (sorted.get(0) != 10) $fatal(1, "FAIL: sorted[0]");
    if (sorted.get(1) != 20) $fatal(1, "FAIL: sorted[1]");
    if (sorted.get(2) != 30) $fatal(1, "FAIL: sorted[2]");
    if (sorted.get(3) != 40) $fatal(1, "FAIL: sorted[3]");
    if (sorted.get(4) != 50) $fatal(1, "FAIL: sorted[4]");

    if (sorted.min() != 10) $fatal(1, "FAIL: min");
    if (sorted.max() != 50) $fatal(1, "FAIL: max");

    $display("PASS: Parameterized class inheritance");
    $finish(0);
  end
endmodule
