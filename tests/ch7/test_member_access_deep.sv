/*
:name: test_member_access_deep
:description: array methods, §8.5 class member access
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 8.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_deep.expected
*/
// IEEE 1800-2023 §7.12.1 array methods, §8.5 class member access

module tb;
  int pass_count = 0;
  int fail_count = 0;

  // Class definitions at module scope (§8.3)
  class Inner;
    int value;
    function new(int v);
      value = v;
    endfunction
  endclass

  class Outer;
    Inner inner;
    string name;
    function new(string n, int v);
      name = n;
      inner = new(v);
    endfunction
  endclass

  // Test 1: Queue locator methods
  task automatic test_queue_locator;
    int q[$] = '{3, 1, 4, 1, 5, 9, 2, 6};
    int result[$];

    // find
    result = q.find with (item > 4);
    if (result.size() == 3) begin
      pass_count++;
      $display("PASS: queue find");
    end else begin
      fail_count++;
      $display("FAIL: queue find: size=%0d", result.size());
    end

    // find_first
    result = q.find_first with (item > 4);
    if (result.size() == 1 && result[0] == 5) begin
      pass_count++;
      $display("PASS: queue find_first");
    end else begin
      fail_count++;
      $display("FAIL: queue find_first");
    end

    // find_last
    result = q.find_last with (item > 4);
    if (result.size() == 1 && result[0] == 6) begin
      pass_count++;
      $display("PASS: queue find_last");
    end else begin
      fail_count++;
      $display("FAIL: queue find_last");
    end

    // find_index
    result = q.find_index with (item == 4);
    if (result.size() == 1 && result[0] == 2) begin
      pass_count++;
      $display("PASS: queue find_index");
    end else begin
      fail_count++;
      $display("FAIL: queue find_index");
    end
  endtask

  // Test 2: Array reduction methods
  task automatic test_array_reduction;
    int arr[] = new[5];
    arr = '{1, 2, 3, 4, 5};

    if (arr.sum() == 15) begin
      pass_count++;
      $display("PASS: array sum");
    end else begin
      fail_count++;
      $display("FAIL: array sum: got %0d", arr.sum());
    end

    if (arr.product() == 120) begin
      pass_count++;
      $display("PASS: array product");
    end else begin
      fail_count++;
      $display("FAIL: array product: got %0d", arr.product());
    end
  endtask

  // Test 3: Queue sort/rsort/reverse
  task automatic test_queue_ordering;
    int q[$] = '{5, 3, 8, 1, 9};

    q.sort();
    if (q[0] == 1 && q[4] == 9) begin
      pass_count++;
      $display("PASS: queue sort");
    end else begin
      fail_count++;
      $display("FAIL: queue sort");
    end

    q.rsort();
    if (q[0] == 9 && q[4] == 1) begin
      pass_count++;
      $display("PASS: queue rsort");
    end else begin
      fail_count++;
      $display("FAIL: queue rsort");
    end

    q.reverse();
    if (q[0] == 1 && q[4] == 9) begin
      pass_count++;
      $display("PASS: queue reverse");
    end else begin
      fail_count++;
      $display("FAIL: queue reverse");
    end
  endtask

  // Test 4: Dynamic array methods
  task automatic test_dynarray_methods;
    int da[];
    int minq[$], maxq[$];
    da = new[5];
    da = '{10, 20, 30, 40, 50};

    if (da.size() == 5) begin
      pass_count++;
      $display("PASS: dynamic array size");
    end else begin
      fail_count++;
      $display("FAIL: dynamic array size");
    end

    // min/max (return queues)
    minq = da.min();
    if (minq.size() > 0 && minq[0] == 10) begin
      pass_count++;
      $display("PASS: dynamic array min");
    end else begin
      fail_count++;
      $display("FAIL: dynamic array min");
    end

    maxq = da.max();
    if (maxq.size() > 0 && maxq[0] == 50) begin
      pass_count++;
      $display("PASS: dynamic array max");
    end else begin
      fail_count++;
      $display("FAIL: dynamic array max");
    end
  endtask

  // Test 5: String methods
  task automatic test_string_methods;
    string s = "Hello, World!";

    if (s.len() == 13) begin
      pass_count++;
      $display("PASS: string len");
    end else begin
      fail_count++;
      $display("FAIL: string len: got %0d", s.len());
    end

    if (s.toupper() == "HELLO, WORLD!") begin
      pass_count++;
      $display("PASS: string toupper");
    end else begin
      fail_count++;
      $display("FAIL: string toupper");
    end

    if (s.tolower() == "hello, world!") begin
      pass_count++;
      $display("PASS: string tolower");
    end else begin
      fail_count++;
      $display("FAIL: string tolower");
    end

    if (s.substr(0, 4) == "Hello") begin
      pass_count++;
      $display("PASS: string substr");
    end else begin
      fail_count++;
      $display("FAIL: string substr: got '%s'", s.substr(0, 4));
    end
  endtask

  // Test 6: Class member access chain
  task automatic test_class_chain;
    Outer obj = new("test", 42);
    if (obj.inner.value == 42 && obj.name == "test") begin
      pass_count++;
      $display("PASS: class member chain access");
    end else begin
      fail_count++;
      $display("FAIL: class member chain access");
    end
  endtask

  // Test 7: Associative array methods
  task automatic test_assoc_methods;
    int aa[string];
    aa["alpha"] = 1;
    aa["beta"] = 2;
    aa["gamma"] = 3;

    if (aa.size() == 3) begin
      pass_count++;
      $display("PASS: assoc array size");
    end else begin
      fail_count++;
      $display("FAIL: assoc array size");
    end

    if (aa.exists("beta")) begin
      pass_count++;
      $display("PASS: assoc array exists");
    end else begin
      fail_count++;
      $display("FAIL: assoc array exists");
    end

    aa.delete("beta");
    if (aa.size() == 2) begin
      pass_count++;
      $display("PASS: assoc array delete");
    end else begin
      fail_count++;
      $display("FAIL: assoc array delete");
    end
  endtask

  initial begin
    test_queue_locator();
    test_array_reduction();
    test_queue_ordering();
    test_dynarray_methods();
    test_string_methods();
    test_class_chain();
    test_assoc_methods();

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
