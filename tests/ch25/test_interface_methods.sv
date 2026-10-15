/*
:name: test_interface_methods
:description: Tasks and functions in interfaces
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_methods.expected
*/
// IEEE 1800-2023 §25.5.4: Tasks and functions in interfaces
// Tests interface methods (tasks and functions)
// Verifies interface-defined behavior

interface counter_if;
    logic [15:0] count;
    logic [15:0] max_value;

    // Initialize counter
    function automatic void init(input logic [15:0] max);
        count = 0;
        max_value = max;
    endfunction

    // Increment counter
    function automatic logic [15:0] increment();
        if (count < max_value)
            count = count + 1;
        return count;
    endfunction

    // Reset counter
    function automatic void reset();
        count = 0;
    endfunction

    // Check if at max
    function automatic bit at_max();
        return (count == max_value);
    endfunction

    // Get current value
    function automatic logic [15:0] get_count();
        return count;
    endfunction
endinterface

module test_interface_methods;
    int pass_count = 0;
    int fail_count = 0;

    counter_if counter();

    initial begin
        logic [15:0] val;

        $display("=== IEEE 1800-2023 §25.5.4: Interface Methods ===");

        // Test 1: Initialize
        counter.init(10);
        if (counter.count == 0 && counter.max_value == 10) begin
            $display("PASS: init() works, count=0, max=10");
            pass_count++;
        end else begin
            $display("FAIL: init() wrong, count=%0d, max=%0d", counter.count, counter.max_value);
            fail_count++;
        end

        // Test 2: Increment
        val = counter.increment();
        if (val == 1 && counter.count == 1) begin
            $display("PASS: increment() returns 1");
            pass_count++;
        end else begin
            $display("FAIL: increment() returned %0d", val);
            fail_count++;
        end

        // Test 3: Multiple increments
        counter.increment();
        counter.increment();
        counter.increment();
        if (counter.get_count() == 4) begin
            $display("PASS: Multiple increments, count = 4");
            pass_count++;
        end else begin
            $display("FAIL: count = %0d, expected 4", counter.get_count());
            fail_count++;
        end

        // Test 4: at_max check (not at max yet)
        if (!counter.at_max()) begin
            $display("PASS: at_max() = 0 when not at max");
            pass_count++;
        end else begin
            $display("FAIL: at_max() wrong");
            fail_count++;
        end

        // Test 5: Increment to max
        repeat(6) counter.increment();
        if (counter.at_max()) begin
            $display("PASS: at_max() = 1 when at max");
            pass_count++;
        end else begin
            $display("FAIL: at_max() should be 1, count=%0d", counter.count);
            fail_count++;
        end

        // Test 6: Reset
        counter.reset();
        if (counter.count == 0) begin
            $display("PASS: reset() works");
            pass_count++;
        end else begin
            $display("FAIL: reset() failed, count = %0d", counter.count);
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
