/*
:name: test_member_access_cast
:description: Test $cast with member access expressions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 8.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access_cast.expected
*/
// Checks $cast with class handles and with a class member as the destination
// (6.24.2, 8.16).

class Base;
    int value;
    string name;
endclass

class Derived extends Base;
    int extra;
endclass

module test_member_cast;
    Base b;
    Derived d;
    Derived d2;
    int pass_count;

    initial begin
        pass_count = 0;
        b = new;
        d = new;

        // Test 1: direct member assignment
        b.value = 42;
        if (b.value == 42) begin
            pass_count++;
            $display("Test 1 PASS: b.value = %0d", b.value);
        end else $display("Test 1 FAIL: b.value = %0d", b.value);

        // Test 2: upcast with $cast; b then refers to the Derived object
        d.value = 100;
        d.extra = 200;
        if ($cast(b, d) && b == d && b.value == 100) begin
            pass_count++;
            $display("Test 2 PASS: b.value = %0d", b.value);
        end else $display("Test 2 FAIL");

        // Test 3: $cast with a class member as the destination
        b.value = 0;
        if ($cast(b.value, 99) && b.value == 99 && d.value == 99) begin
            pass_count++;
            $display("Test 3 PASS: b.value = %0d", b.value);
        end else $display("Test 3 FAIL: b.value = %0d", b.value);

        // Test 4: downcast back to Derived and read the subclass member
        b.name = "test";
        if ($cast(d2, b) && d2.extra == 200 && d2.name == "test") begin
            pass_count++;
            $display("Test 4 PASS: d2.extra = %0d, d2.name = %s", d2.extra, d2.name);
        end else $display("Test 4 FAIL");

        $display("%0d/4 passed", pass_count);
        $finish;
    end
endmodule
