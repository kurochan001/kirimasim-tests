/*
:name: test_member_access_chain
:description: Test chained member access (IEEE 1800-2023 Section 7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 7.2.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_chain.expected
*/
// Test chained member access (IEEE 1800-2023 Section 7)

class Inner;
  int value;
  function new(int v);
    value = v;
  endfunction
endclass

class Outer;
  Inner inner;
  int arr[4];
  function new();
    inner = new(100);
    arr = '{10, 20, 30, 40};
  endfunction
endclass

module test_member_access_chain;
  Outer obj;
  int pass_count;

  typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
  } pair_t;

  typedef struct packed {
    pair_t pair;
    logic [15:0] c;
  } nested_t;

  nested_t ns;

  initial begin
    pass_count = 0;
    obj = new();

    // Test 1: Simple member access
    if (obj.arr[0] == 10) pass_count++;

    // Test 2: Chained object member
    if (obj.inner.value == 100) pass_count++;

    // Test 3: Array element access
    if (obj.arr[2] == 30) pass_count++;

    // Test 4: Modify through chain
    obj.inner.value = 200;
    if (obj.inner.value == 200) pass_count++;

    // Test 5: Struct member access
    ns.pair.a = 8'hAA;
    ns.pair.b = 8'hBB;
    ns.c = 16'hCCDD;
    if (ns.pair.a == 8'hAA) pass_count++;
    if (ns.pair.b == 8'hBB) pass_count++;

    // Test 6: Nested struct as whole
    if (ns.pair == 16'hAABB) pass_count++;

    // Test 7: Array element modification
    obj.arr[1] = 99;
    if (obj.arr[1] == 99) pass_count++;

    $display("Member access chain tests: %0d/8 passed", pass_count);
    if (pass_count == 8) begin
      $display("PASS: Member access chain tests");
    end else begin
      $display("FAIL: Some member access tests failed");
    end
  end
endmodule
