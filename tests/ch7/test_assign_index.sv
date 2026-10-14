/*
:name: test_assign_index
:description: Indexed assignments
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 12.7.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_index.expected
*/
// IEEE 1800-2023 §10.4: Indexed assignments
module test_assign_index;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] arr [4];
    int idx;

    initial begin
        // Test 1: Variable index assign
        arr[0] = 8'h00; arr[1] = 8'h00; arr[2] = 8'h00; arr[3] = 8'h00;
        idx = 2;
        arr[idx] = 8'hAB;
        if (arr[2] == 8'hAB) begin
            $display("Test 1 PASS: var index = %02h", arr[2]);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", arr[2]);
            fail_count++;
        end

        // Test 2: Computed index
        idx = 1;
        arr[idx + 1] = 8'hCD;
        if (arr[2] == 8'hCD) begin
            $display("Test 2 PASS: computed idx = %02h", arr[2]);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", arr[2]);
            fail_count++;
        end

        // Test 3: Loop index assign
        foreach (arr[i]) begin
            arr[i] = i * 16;
        end
        if (arr[0] == 8'h00 && arr[1] == 8'h10 && arr[2] == 8'h20 && arr[3] == 8'h30) begin
            $display("Test 3 PASS: loop assign");
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
