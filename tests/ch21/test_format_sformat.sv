/*
:name: test_format_sformat
:description: $sformatf system function
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_sformat.expected
*/
// IEEE 1800-2023 §21.3.3: $sformatf system function
module test_format_sformat;
    int pass_count = 0;
    int fail_count = 0;
    string s;

    initial begin
        // Test 1: Integer format using sformatf
        s = $sformatf("value=%0d", 42);
        if (s == "value=42") begin
            $display("Test 1 PASS: sformatf int");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Hex format
        s = $sformatf("hex=%0h", 255);
        if (s == "hex=ff") begin
            $display("Test 2 PASS: sformatf hex");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 3: Octal format
        s = $sformatf("oct=%0o", 64);
        if (s == "oct=100") begin
            $display("Test 3 PASS: sformatf octal");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got '%s'", s);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
