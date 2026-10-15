/*
:name: test_assign_array
:description: Array assignments
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.6 10.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_array.expected
*/
// IEEE 1800-2023 §10.4: Array assignments
module test_assign_array;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] arr [4];
    logic [7:0] arr2 [4];

    initial begin
        // Test 1: Individual element assign
        arr[0] = 8'hAA;
        arr[1] = 8'hBB;
        arr[2] = 8'hCC;
        arr[3] = 8'hDD;
        if (arr[0] == 8'hAA && arr[3] == 8'hDD) begin
            $display("Test 1 PASS: element assign");
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Array copy
        arr2 = arr;
        if (arr2[0] == 8'hAA && arr2[3] == 8'hDD) begin
            $display("Test 2 PASS: array copy");
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Reassign element
        arr[0] = 8'hFF;
        if (arr[0] == 8'hFF) begin
            $display("Test 3 PASS: reassign element");
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
