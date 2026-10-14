/*
:name: test_class_method_2
:description: Class Method Tests
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_method_2.expected
*/
// IEEE 1800-2023 Section 8.6 - Class Method Tests
module test_class_method;
    int pass_count = 0;
    int fail_count = 0;

    class Calculator;
        int value;

        function new();
            value = 0;
        endfunction

        function int get_value();
            return value;
        endfunction

        function void set_value(int v);
            value = v;
        endfunction

        function int add(int v);
            value = value + v;
            return value;
        endfunction

        function int multiply(int v);
            value = value * v;
            return value;
        endfunction
    endclass

    initial begin
        Calculator calc;
        int result;

        $display("=== IEEE 1800-2023 Class Method Tests ===");

        calc = new();

        // Test 1: Get initial
        $display("Test 1: Get initial");
        result = calc.get_value();
        if (result == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Set value
        $display("Test 2: Set value");
        calc.set_value(10);
        result = calc.get_value();
        if (result == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Add
        $display("Test 3: Add");
        result = calc.add(5);
        if (result == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Multiply
        $display("Test 4: Multiply");
        result = calc.multiply(2);
        if (result == 30) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Chain operations
        $display("Test 5: Chain ops");
        calc.set_value(0);
        calc.add(10);
        calc.add(20);
        result = calc.get_value();
        if (result == 30) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Multiple objects
        $display("Test 6: Multiple objects");
        begin
            Calculator calc2;
            calc2 = new();
            calc2.set_value(100);
            if (calc.get_value() == 30 && calc2.get_value() == 100) begin 
                $display("Test 6 PASS"); pass_count++; 
            end
            else begin $display("Test 6 FAIL"); fail_count++; end
        end

        // Test 7: Negative values
        $display("Test 7: Negative values");
        calc.set_value(-10);
        result = calc.add(5);
        if (result == -5) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Multiply zero
        $display("Test 8: Multiply zero");
        calc.set_value(100);
        result = calc.multiply(0);
        if (result == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
