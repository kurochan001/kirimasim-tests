/*
:name: test_numeric_utils
:description: Test for system task numeric utilities
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5 11.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_numeric_utils.expected
*/
// Test for system task numeric utilities
// IEEE 1800-2023 §20

module test_numeric_utils;
    int val;
    real r;
    logic [31:0] bits;
    logic [63:0] bits64;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: $rtoi
        test_count++;
        r = 3.7;
        val = $rtoi(r);
        if (val == 3) begin
            $display("Test 1: $rtoi PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL val=%0d", val);
        end

        // Test 2: $itor
        test_count++;
        val = 42;
        r = $itor(val);
        if (r == 42.0) begin
            $display("Test 2: $itor PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: $realtobits
        test_count++;
        r = 1.5;
        bits64 = $realtobits(r);
        if (bits64 == 64'h3FF8_0000_0000_0000) begin
            $display("Test 3: $realtobits PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL bits=%h", bits64);
        end

        // Test 4: $bitstoreal
        test_count++;
        r = $bitstoreal(64'h4004_0000_0000_0000);
        if (r == 2.5) begin
            $display("Test 4: $bitstoreal PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL r=%f", r);
        end

        // Test 5: $signed
        test_count++;
        bits = 32'hFFFFFFFF;
        val = $signed(bits);
        if (val == -1) begin
            $display("Test 5: $signed PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: $unsigned
        test_count++;
        val = -1;
        bits = $unsigned(val);
        if (bits == 32'hFFFFFFFF) begin
            $display("Test 6: $unsigned PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
