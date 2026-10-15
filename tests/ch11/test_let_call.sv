/*
:name: test_let_call
:description: Test: Let expression calls
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_call.expected
*/
// Test: Let expression calls
// let declarations called with arguments, and a let that calls another

module test_let_call;
    // Basic arithmetic lets
    let square(x) = x * x;
    let cube(x) = x * x * x;
    let power2(n) = 1 << n;

    // Bit manipulation lets
    let get_bit(val, pos) = (val >> pos) & 1;
    let set_bit(val, pos) = val | (1 << pos);
    let clear_bit(val, pos) = val & ~(1 << pos);

    // Conditional lets
    let is_even(x) = (x % 2) == 0;
    let is_power_of_2(x) = (x != 0) && ((x & (x - 1)) == 0);

    // Composition let
    let double_square(x) = square(x) * 2;

    int val, result;
    bit flag;
    int pass_count;
    int fail_count;

    initial begin
        pass_count = 0;
        fail_count = 0;

        // Test 1: Square call
        val = 5;
        result = square(val);
        if (result == 25) begin
            $display("Test 1 PASS: square(5) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: square(5) = %0d, expected 25", result);
            fail_count++;
        end

        // Test 2: Power of 2 call
        result = power2(4);
        if (result == 16) begin
            $display("Test 2 PASS: power2(4) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: power2(4) = %0d, expected 16", result);
            fail_count++;
        end

        // Test 3: Bit manipulation calls
        val = 8'b10100000;
        result = get_bit(val, 5);
        if (result == 1) begin
            $display("Test 3 PASS: get_bit(0xA0, 5) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: get_bit = %0d, expected 1", result);
            fail_count++;
        end

        // Test 4: Conditional let call
        flag = is_even(42);
        if (flag == 1) begin
            $display("Test 4 PASS: is_even(42) = true");
            pass_count++;
        end else begin
            $display("Test 4 FAIL: is_even(42) = false");
            fail_count++;
        end

        // Test 5: Nested let calls in expression
        result = square(3) + cube(2);  // 9 + 8 = 17
        if (result == 17) begin
            $display("Test 5 PASS: square(3) + cube(2) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Result = %0d, expected 17", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Let Call Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end
endmodule
