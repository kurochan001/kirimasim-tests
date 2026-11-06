/*
:name: test_dynamic_cast
:description: Assignment and casting
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec
:spec_check: ai
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

    // IEEE 1800-2023 §8.16: a handle variable holding null is not an object and
    // is not the literal null, so this downcast fails and, as a function call,
    // leaves the destination unchanged (6.24.2). The 5.052 release of Verilator
    // lets it succeed and assign null.
    b_ref = null;
    d_ref = d;
    if ($cast(d_ref, b_ref)) begin
      $fatal(1, "FAIL: casting a null handle should fail");
    end
    if (d_ref != d) begin
      $fatal(1, "FAIL: a failed cast should keep the destination");
    end
    $display("  Null handle cast correctly failed and kept the destination");

    // §8.16: the literal null is the case that succeeds, and it assigns null.
    if (!$cast(d_ref, null)) begin
      $fatal(1, "FAIL: casting the literal null should succeed");
    end
    if (d_ref != null) begin
      $fatal(1, "FAIL: casting the literal null should yield null");
    end
    $display("  Literal null cast correctly succeeded and yielded null");

    $display("PASS: Dynamic casting");
    $finish(0);
  end
endmodule
