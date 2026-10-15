/*
:name: test_dynamic_cast
:description: Assignment and casting
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_cast.expected
*/
// IEEE 1800-2023 Section 8.16 - Casting
// Test: Dynamic casting with $cast()

module test_dynamic_cast;
  class Base;
    int base_val = 10;
  endclass

  class Derived extends Base;
    int derived_val = 20;
  endclass

  class Unrelated;
    int other_val = 30;
  endclass

  initial begin
    static Base b = new();
    static Derived d = new();
    Base b_ref;
    Derived d_ref;
    static Unrelated u = new();

    // Successful upcast (derived to base) - always safe
    b_ref = d;
    if (b_ref == null) $fatal(1, "FAIL: upcast null");
    if (b_ref.base_val != 10) $fatal(1, "FAIL: upcast base_val");

    // Successful downcast using $cast
    b_ref = d;  // Base reference pointing to Derived object
    if (!$cast(d_ref, b_ref)) begin
      $fatal(1, "FAIL: downcast should succeed when types match");
    end
    if (d_ref.derived_val != 20) $fatal(1, "FAIL: downcast derived_val");

    // Failed downcast - base object cannot be cast to derived
    b_ref = b;  // Base reference pointing to Base object
    if ($cast(d_ref, b_ref)) begin
      $fatal(1, "FAIL: downcast should fail for pure base object");
    end
    $display("  Downcast correctly failed for pure base object");

    // Test null casting. IEEE 1800-2023 §8.16/§8.21: the special value null is
    // assignable to any class handle, so $cast of a null source SUCCEEDS and
    // non-conformant behavior.)
    b_ref = null;
    d_ref = null;
    if (!$cast(d_ref, b_ref)) begin
      $fatal(1, "FAIL: casting null should succeed");
    end
    if (d_ref != null) begin
      $fatal(1, "FAIL: casting null should yield null");
    end
    $display("  Null cast correctly succeeded and yielded null");

    $display("PASS: Dynamic casting");
    $finish(0);
  end
endmodule
