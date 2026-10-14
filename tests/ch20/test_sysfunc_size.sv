/*
:name: test_sysfunc_size
:description: $size system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_size.expected
*/
// IEEE 1800-2023 §20.7: $size system function
module test_sysfunc_size;
    int pass_count = 0;
    int fail_count = 0;
    int result;
    logic [7:0] arr [4];
    logic [7:0] arr2 [8];
    int darr[];

    initial begin
        result = $size(arr);
        if (result == 4) begin
            $display("Test 1 PASS: size(arr) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 2: Larger array
        result = $size(arr2);
        if (result == 8) begin
            $display("Test 2 PASS: size(arr2) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 3: Dynamic array (empty)
        darr = new[5];
        result = $size(darr);
        if (result == 5) begin
            $display("Test 3 PASS: size(darr) = %0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", result);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
