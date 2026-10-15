/*
:name: test_class_null_handle
:description: Test: Null handle detection (check if handle is null before use)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_null_handle.expected
*/
// Test: Null handle detection (check if handle is null before use)
module test_class_null_handle;

  class Item;
    int value;

    function new(int v);
      value = v;
    endfunction

    function int get_value();
      return value;
    endfunction
  endclass

  class Container;
    Item item;

    function new();
      item = null;
    endfunction

    function bit has_item();
      return (item != null);
    endfunction

    function void set_item(Item i);
      item = i;
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Item a, b;
    Container c;

    // Check 1: uninitialized handle is null
    a = null;
    if (a == null) begin pass_cnt++; $display("PASS: explicit null == null"); end
    else begin fail_cnt++; $display("FAIL: explicit null not detected"); end

    // Check 2: constructed handle is not null
    b = new(55);
    if (b != null) begin pass_cnt++; $display("PASS: constructed handle != null"); end
    else begin fail_cnt++; $display("FAIL: constructed handle is null"); end

    // Check 3: container starts with null item
    c = new();
    if (!c.has_item()) begin pass_cnt++; $display("PASS: container item initially null"); end
    else begin fail_cnt++; $display("FAIL: container item not null"); end

    // Check 4: after set_item, not null
    c.set_item(b);
    if (c.has_item()) begin pass_cnt++; $display("PASS: container has item after set"); end
    else begin fail_cnt++; $display("FAIL: container item still null"); end

    // Check 5: access through container
    if (c.item.get_value() == 55) begin pass_cnt++; $display("PASS: container item value == 55"); end
    else begin fail_cnt++; $display("FAIL: container item value = %0d", c.item.get_value()); end

    // Check 6: set back to null
    c.set_item(null);
    if (c.item == null) begin pass_cnt++; $display("PASS: item set back to null"); end
    else begin fail_cnt++; $display("FAIL: item not null after clearing"); end

    // Check 7: two handles to same object
    a = b;
    if (a == b) begin pass_cnt++; $display("PASS: handle equality (same object)"); end
    else begin fail_cnt++; $display("FAIL: handle equality failed"); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
