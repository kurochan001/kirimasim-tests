/*
:name: test_assoc_array_methods_basic
:description: Associative array methods: exists/first/next/delete
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_methods_basic.expected
*/
// Associative array methods: exists/first/next/delete
module test_assoc_array_methods_basic;
  typedef int int_t;
  int arr[string];
  string k; int v; int cnt;
  initial begin
    arr["a"] = 1; arr["b"] = 2; arr["c"] = 3;
    assert(arr.exists("b"));
    cnt = 0; if (arr.first(k)) begin cnt++; while (arr.next(k)) cnt++; end
    assert(cnt==3);
    arr.delete("b");
    assert(!arr.exists("b"));
    $display("TEST PASSED: associative array methods basic");
    $finish;
  end
endmodule
