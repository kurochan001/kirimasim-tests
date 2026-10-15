/*
:name: test_unpack_arr
:description: Unpacked Array Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpack_arr.expected
*/
// IEEE 1800-2023 Section 7.4 - Unpacked Array Tests
module test_unpack_arr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int arr[3][2];
        int flat[6];
        int i, j, val;

        $display("=== IEEE 1800-2023 Unpacked Array Tests ===");

        $display("Test 1: 2D init");
        val = 0;
        for (i = 0; i < 3; i++)
            for (j = 0; j < 2; j++) begin
                arr[i][j] = val;
                val++;
            end
        if (arr[0][0] == 0 && arr[2][1] == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: 2D access");
        if (arr[1][0] == 2 && arr[1][1] == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: 2D modify");
        arr[0][1] = 99;
        if (arr[0][1] == 99) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", arr[0][1]); fail_count++; end

        $display("Test 4: Flat init");
        for (i = 0; i < 6; i++)
            flat[i] = i * 10;
        if (flat[0] == 0 && flat[5] == 50) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Flat sum");
        val = 0;
        for (i = 0; i < 6; i++)
            val = val + flat[i];
        if (val == 150) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", val); fail_count++; end

        $display("Test 6: Row sum");
        val = arr[0][0] + arr[0][1];
        if (val == 99) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", val); fail_count++; end

        $display("Test 7: Col access");
        if (arr[0][0] == 0 && arr[1][0] == 2 && arr[2][0] == 4) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Bounds check");
        arr[2][1] = 100;
        if (arr[2][1] == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
