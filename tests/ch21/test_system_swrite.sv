/*
:name: test_system_swrite
:description: $swrite string format
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_swrite.expected
*/
// $swrite string format
module test_swrite;
    string str;
    string str2;
    integer int_val;
    real real_val;
    reg [31:0] hex_val;
    reg [7:0] byte_val;

    initial begin
        int_val = 42;
        real_val = 3.14159;
        hex_val = 32'hDEADBEEF;
        byte_val = 8'hAB;

        // Test 1: Basic string write
        $swrite(str, "Hello World");
        if (str == "Hello World") begin
            $display("PASS: Test 1 - $swrite basic string: %s", str);
        end else begin
            $display("FAIL: Test 1 - Expected 'Hello World', got '%s'", str);
        end

        // Test 2: Integer formatting
        $swrite(str, "Value: %0d", int_val);
        if (str == "Value: 42") begin
            $display("PASS: Test 2 - $swrite integer: %s", str);
        end else begin
            $display("FAIL: Test 2 - Expected 'Value: 42', got '%s'", str);
        end

        // Test 3: Hex formatting
        $swrite(str, "Hex: %h", hex_val);
        $display("PASS: Test 3 - $swrite hex: %s", str);

        // Test 4: Multiple values
        $swrite(str, "int=%0d hex=%h byte=%h", int_val, hex_val, byte_val);
        $display("PASS: Test 4 - $swrite multiple: %s", str);

        // Test 5: Overwrite existing string
        str = "original";
        $swrite(str, "overwritten");
        if (str == "overwritten") begin
            $display("PASS: Test 5 - $swrite overwrites: %s", str);
        end else begin
            $display("FAIL: Test 5 - Failed to overwrite, got '%s'", str);
        end

        $finish;
    end
endmodule
