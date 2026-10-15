/*
:name: test_param_class_nested
:description: Parameterized Classes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 6.18
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_nested.expected
*/
// IEEE 1800-2023 Section 8.25 - Parameterized Classes
// Test: Nested parameterized classes

module test_param_class_nested;
  // Inner parameterized class
  class Pair #(type T1 = int, type T2 = int);
    T1 first;
    T2 second;

    function new(T1 f, T2 s);
      first = f;
      second = s;
    endfunction
  endclass

  // Outer parameterized class using inner
  class PairList #(type T1 = int, type T2 = int);
    typedef Pair#(T1, T2) pair_t;
    pair_t items[$];

    function void add(T1 first, T2 second);
      pair_t p = new(first, second);
      items.push_back(p);
    endfunction

    function pair_t get(int index);
      if (index < items.size()) return items[index];
      return null;
    endfunction

    function int size();
      return items.size();
    endfunction
  endclass

  initial begin
    static PairList#(int, string) int_str_list = new();
    static PairList#(string, real) str_real_list = new();

    // Test int-string pairs
    int_str_list.add(1, "one");
    int_str_list.add(2, "two");
    int_str_list.add(3, "three");

    if (int_str_list.size() != 3) $fatal(1, "FAIL: int_str_list size");

    begin
      Pair#(int, string) p;
      p = int_str_list.get(0);
      if (p == null) $fatal(1, "FAIL: int_str_list get(0) null");
      if (p.first != 1) $fatal(1, "FAIL: pair.first");
      if (p.second != "one") $fatal(1, "FAIL: pair.second");
    end

    // Test string-real pairs
    str_real_list.add("pi", 3.14159);
    str_real_list.add("e", 2.71828);

    if (str_real_list.size() != 2) $fatal(1, "FAIL: str_real_list size");

    begin
      Pair#(string, real) p;
      p = str_real_list.get(1);
      if (p == null) $fatal(1, "FAIL: str_real_list get(1) null");
      if (p.first != "e") $fatal(1, "FAIL: pair.first e");
      if (p.second != 2.71828) $fatal(1, "FAIL: pair.second e");
    end

    $display("PASS: Nested parameterized classes");
    $finish(0);
  end
endmodule
