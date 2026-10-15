/*
:name: test_sscanf_4
:description: $sscanf string parsing
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_4.expected
*/
// $sscanf string parsing
module test_sscanf;
    integer val1, val2, val3;
    reg [31:0] hex_val;
    real rval;
    string str;
    integer num_matched;
    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $sscanf single decimal
        num_matched = $sscanf("12345", "%d", val1);
        if (num_matched == 1 && val1 == 12345) begin
            $display("Test 1: $sscanf decimal - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $sscanf decimal - FAIL (matched=%0d, val=%0d)", num_matched, val1);
        end

        // Test 2: $sscanf hex value
        num_matched = $sscanf("CAFE", "%h", hex_val);
        if (num_matched == 1 && hex_val == 32'hCAFE) begin
            $display("Test 2: $sscanf hex - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $sscanf hex - FAIL (matched=%0d, val=%h)", num_matched, hex_val);
        end

        // Test 3: $sscanf multiple values
        num_matched = $sscanf("10 20 30", "%d %d %d", val1, val2, val3);
        if (num_matched == 3 && val1 == 10 && val2 == 20 && val3 == 30) begin
            $display("Test 3: $sscanf multi-val - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $sscanf multi-val - FAIL");
        end

        // Test 4: $sscanf with string
        num_matched = $sscanf("Hello World", "%s", str);
        if (num_matched == 1 && str == "Hello") begin
            $display("Test 4: $sscanf string - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: $sscanf string - FAIL (got '%s')", str);
        end

        // Test 5: $sscanf partial match
        num_matched = $sscanf("100 abc", "%d %d", val1, val2);
        if (num_matched == 1 && val1 == 100) begin
            $display("Test 5: $sscanf partial - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $sscanf partial - FAIL (matched=%0d)", num_matched);
        end

        if (pass_count == 5)
            $display("All sscanf tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
