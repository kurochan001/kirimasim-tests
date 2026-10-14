/*
:name: test_sformat_2
:description: $sformat and $sformatf
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.2.1.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_2.expected
*/
// IEEE 1800-2023 §21.3.3 $sformat and $sformatf
// Tests string formatting system tasks

module test_sformat;
    string result;
    string temp;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: $sformatf with integer
        result = $sformatf("Value = %0d", 42);
        if (result == "Value = 42") begin
            $display("PASS: $sformatf with integer");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf - result='%s'", result);
            fail_count++;
        end

        // Test 2: $sformatf with hex
        result = $sformatf("Hex = %h", 8'hAB);
        if (result == "Hex = ab") begin
            $display("PASS: $sformatf with hex");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf hex - result='%s'", result);
            fail_count++;
        end

        // Test 3: $sformatf with binary
        result = $sformatf("Binary = %4b", 4'b1010);
        if (result == "Binary = 1010") begin
            $display("PASS: $sformatf with binary format");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf binary - result='%s'", result);
            fail_count++;
        end

        // Test 4: $sformatf with multiple values
        result = $sformatf("a=%0d, b=%0d, c=%0d", 1, 2, 3);
        if (result == "a=1, b=2, c=3") begin
            $display("PASS: $sformatf with multiple values");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf multiple - result='%s'", result);
            fail_count++;
        end

        // Test 5: $sformatf with string
        result = $sformatf("Name = %s", "test");
        if (result == "Name = test") begin
            $display("PASS: $sformatf with string");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf string - result='%s'", result);
            fail_count++;
        end

        // Test 6: $sformat with explicit output
        $sformat(temp, "Result = %0d", 100);
        if (temp == "Result = 100") begin
            $display("PASS: $sformat with output argument");
            pass_count++;
        end else begin
            $display("FAIL: $sformat - result='%s'", temp);
            fail_count++;
        end

        // Test 7: $sformatf with width specifier
        result = $sformatf("Padded = %5d", 7);
        if (result == "Padded =     7") begin
            $display("PASS: $sformatf with width specifier");
            pass_count++;
        end else begin
            $display("FAIL: $sformatf width - result='%s'", result);
            fail_count++;
        end

        $display("");
        $display("=== $sformat/$sformatf Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
