/*
:name: test_plusargs_types
:description: $value$plusargs leaves the variable unchanged when no plusarg matches
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_plusargs_types.expected
*/
// $value$plusargs leaves the variable unchanged when no plusarg matches
module test_plusargs_types;
    int int_val;
    real real_val;
    string str_val;
    logic [31:0] hex_val;

    initial begin
        // Test 1: Integer value
        $display("Test 1: Integer plusarg");
        int_val = 100;
        if ($value$plusargs("INT_VAL=%d", int_val))
            $display("  INT_VAL from args: %0d", int_val);
        else
            $display("  INT_VAL default: %0d", int_val);

        // Test 2: Real value
        $display("Test 2: Real plusarg");
        real_val = 3.14;
        if ($value$plusargs("REAL_VAL=%f", real_val))
            $display("  REAL_VAL from args: %f", real_val);
        else
            $display("  REAL_VAL default: %f", real_val);

        // Test 3: String value
        $display("Test 3: String plusarg");
        str_val = "default";
        if ($value$plusargs("STR_VAL=%s", str_val))
            $display("  STR_VAL from args: %s", str_val);
        else
            $display("  STR_VAL default: %s", str_val);

        // Test 4: Hex value
        $display("Test 4: Hex plusarg");
        hex_val = 32'hDEAD_BEEF;
        if ($value$plusargs("HEX_VAL=%h", hex_val))
            $display("  HEX_VAL from args: %h", hex_val);
        else
            $display("  HEX_VAL default: %h", hex_val);

        // Test 5: Binary value
        $display("Test 5: Binary plusarg");
        begin
            static logic [7:0] bin_val = 8'b10101010;
            if ($value$plusargs("BIN_VAL=%b", bin_val))
                $display("  BIN_VAL from args: %b", bin_val);
            else
                $display("  BIN_VAL default: %b", bin_val);
        end

        // Test 6: Octal value
        $display("Test 6: Octal plusarg");
        begin
            static logic [11:0] oct_val = 12'o7777;
            if ($value$plusargs("OCT_VAL=%o", oct_val))
                $display("  OCT_VAL from args: %o", oct_val);
            else
                $display("  OCT_VAL default: %o", oct_val);
        end

        $display("");
        $display("TEST PASSED: Plusargs types tests completed");
        $finish;
    end
endmodule
