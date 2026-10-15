/*
:name: test_format_array
:description: Array formatting
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_array.expected
*/
// IEEE 1800-2023 §21.2: Array formatting
module test_format_array;
    int pass_count = 0;
    int fail_count = 0;
    int arr[3];
    string s;

    initial begin
        // Test 1: Array elements
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        s = $sformatf("%0d,%0d,%0d", arr[0], arr[1], arr[2]);
        if (s == "1,2,3") begin
            $display("Test 1 PASS: array elements");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Packed array format
        s = $sformatf("sum=%0d", arr[0] + arr[1] + arr[2]);
        if (s == "sum=6") begin
            $display("Test 2 PASS: array sum");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 3: Array in hex
        arr[0] = 255;
        s = $sformatf("hex=%0h", arr[0]);
        if (s == "hex=ff") begin
            $display("Test 3 PASS: array hex");
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
