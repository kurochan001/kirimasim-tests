/*
:name: test_system_cast
:description: Test $cast - dynamic type casting
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_cast.expected
*/
// Test $cast - dynamic type casting
module test_system_cast;
    class Base;
        int value;
        function new(int v = 0);
            value = v;
        endfunction
    endclass

    class Derived extends Base;
        int extra;
        function new(int v = 0, int e = 0);
            super.new(v);
            extra = e;
        endfunction
    endclass

    class Unrelated;
        int data;
    endclass

    Base b;
    Derived d, d2;
    Unrelated u;
    int cast_result;

    initial begin
        // Test 1: Successful downcast (Base handle pointing to Derived object)
        d = new(10, 20);
        b = d;  // Upcast to Base
        cast_result = $cast(d2, b);  // Downcast back to Derived
        if (cast_result == 1 && d2.value == 10 && d2.extra == 20)
            $display("PASS: $cast downcast successful, value=%0d, extra=%0d", d2.value, d2.extra);
        else
            $display("FAIL: $cast downcast failed or wrong values");

        // Test 2: Failed downcast (Base handle pointing to Base object)
        b = new(30);
        cast_result = $cast(d2, b);
        if (cast_result == 0)
            $display("PASS: $cast correctly failed for incompatible types");
        else
            $display("FAIL: $cast should have failed but returned %0d", cast_result);

        // Test 3: Cast to same type
        d = new(40, 50);
        cast_result = $cast(d2, d);
        if (cast_result == 1 && d2.value == 40)
            $display("PASS: $cast same type successful, value=%0d", d2.value);
        else
            $display("FAIL: $cast same type failed");

        // Test 4: Cast null handle
        // A Base variable that holds null is not checked: 8.16 names only the
        // literal null as always succeeding, and readings of the variable case differ.

        // Test 5: Verify original object unchanged after cast
        d = new(60, 70);
        b = d;
        cast_result = $cast(d2, b);
        if (cast_result == 1 && d2 == d && d.value == 60 && d.extra == 70)
            $display("PASS: Original object unchanged after $cast");
        else
            $display("FAIL: Original object was modified");

        $finish;
    end
endmodule
