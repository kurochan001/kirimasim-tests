/*
:name: test_system_sscanf
:description: $sscanf parsing
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_sscanf.expected
*/
// $sscanf parsing
module test_sscanf;
    string input_str;
    integer result;
    integer int_val;
    integer int_val2;
    real real_val;
    reg [31:0] hex_val;
    string str_val;

    initial begin
        // Test 1: Parse single integer
        input_str = "42";
        result = $sscanf(input_str, "%d", int_val);
        if (result == 1 && int_val == 42) begin
            $display("PASS: Test 1 - $sscanf integer: %0d (result=%0d)", int_val, result);
        end else begin
            $display("FAIL: Test 1 - Expected 42, got %0d (result=%0d)", int_val, result);
        end

        // Test 2: Parse hex value
        input_str = "DEADBEEF";
        result = $sscanf(input_str, "%h", hex_val);
        if (result == 1 && hex_val == 32'hDEADBEEF) begin
            $display("PASS: Test 2 - $sscanf hex: %h (result=%0d)", hex_val, result);
        end else begin
            $display("FAIL: Test 2 - Expected DEADBEEF, got %h (result=%0d)", hex_val, result);
        end

        // Test 3: Parse multiple integers
        input_str = "123 456";
        result = $sscanf(input_str, "%d %d", int_val, int_val2);
        if (result == 2 && int_val == 123 && int_val2 == 456) begin
            $display("PASS: Test 3 - $sscanf two integers: %0d, %0d (result=%0d)", int_val, int_val2, result);
        end else begin
            $display("FAIL: Test 3 - Expected 123, 456, got %0d, %0d (result=%0d)", int_val, int_val2, result);
        end

        // Test 4: Parse with prefix text
        input_str = "Value=789";
        result = $sscanf(input_str, "Value=%d", int_val);
        if (result == 1 && int_val == 789) begin
            $display("PASS: Test 4 - $sscanf with prefix: %0d (result=%0d)", int_val, result);
        end else begin
            $display("FAIL: Test 4 - Expected 789, got %0d (result=%0d)", int_val, result);
        end

        // Test 5: Parse real number
        input_str = "3.14159";
        result = $sscanf(input_str, "%f", real_val);
        if (result == 1) begin
            $display("PASS: Test 5 - $sscanf real: %f (result=%0d)", real_val, result);
        end else begin
            $display("FAIL: Test 5 - sscanf real failed (result=%0d)", result);
        end

        $finish;
    end
endmodule
