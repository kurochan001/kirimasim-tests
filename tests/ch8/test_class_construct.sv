/*
:name: test_class_construct
:description: Class Constructor Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_construct.expected
*/
// IEEE 1800-2023 Section 8.7 - Class Constructor Tests
class SimpleClass;
    int value;
    string name;

    function new(int v = 0, string n = "default");
        value = v;
        name = n;
    endfunction
endclass

module test_class_construct;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        SimpleClass obj1, obj2, obj3;

        $display("=== IEEE 1800-2023 Class Constructor Tests ===");

        // Test 1: Default construct
        $display("Test 1: Default");
        obj1 = new();
        if (obj1.value == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", obj1.value); fail_count++; end

        // Test 2: Single arg
        $display("Test 2: Single arg");
        obj2 = new(42);
        if (obj2.value == 42) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", obj2.value); fail_count++; end

        // Test 3: Both args
        $display("Test 3: Both args");
        obj3 = new(100, "test");
        if (obj3.value == 100 && obj3.name == "test") begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Default name
        $display("Test 4: Default name");
        if (obj1.name == "default") begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %s", obj1.name); fail_count++; end

        // Test 5: Negative value
        $display("Test 5: Negative");
        obj1 = new(-10);
        if (obj1.value == -10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", obj1.value); fail_count++; end

        // Test 6: Modify after
        $display("Test 6: Modify");
        obj2.value = 999;
        if (obj2.value == 999) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", obj2.value); fail_count++; end

        // Test 7: Independence
        $display("Test 7: Independence");
        obj1 = new(1);
        obj2 = new(2);
        if (obj1.value == 1 && obj2.value == 2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Zero value
        $display("Test 8: Zero");
        obj3 = new(0, "zero");
        if (obj3.value == 0 && obj3.name == "zero") begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
