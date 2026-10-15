/*
:name: test_value_ext
:description: Test for value operations extended
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_value_ext.expected
*/
// Test for value operations extended
// IEEE 1800-2023 §11.4

module test_value_ext;
    logic [31:0] a, b, c;
    logic signed [31:0] sa, sb, sc;
    logic [63:0] wide;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Unsigned comparison
        test_count++;
        a = 32'h80000000;
        b = 32'h7FFFFFFF;
        if (a > b) begin
            $display("Test 1: Unsigned cmp PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Signed comparison
        test_count++;
        sa = -1;
        sb = 1;
        if (sa < sb) begin
            $display("Test 2: Signed cmp PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Arithmetic shift right
        test_count++;
        sa = -16;
        sc = sa >>> 2;
        if (sc == -4) begin
            $display("Test 3: Arith shift PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL sc=%0d", sc);
        end

        // Test 4: Logical shift right
        test_count++;
        a = 32'h80000000;
        b = a >> 1;
        if (b == 32'h40000000) begin
            $display("Test 4: Logic shift PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL b=%h", b);
        end

        // Test 5: Wide concatenation
        test_count++;
        a = 32'hAAAAAAAA;
        b = 32'h55555555;
        wide = {a, b};
        if (wide == 64'hAAAAAAAA55555555) begin
            $display("Test 5: Wide concat PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL wide=%h", wide);
        end

        // Test 6: Reduction XNOR
        test_count++;
        a = 32'hFFFFFFFF;
        c = ~^a;
        $display("Test 6: Reduction XNOR PASS c=%0d", c);
        pass_count++;

        // Test 7: Equality with X
        test_count++;
        a = 32'h12345678;
        b = 32'h12345678;
        if (a === b) begin
            $display("Test 7: Case equality PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Test 8: Power operator
        test_count++;
        a = 2;
        b = 10;
        c = a ** b;
        if (c == 1024) begin
            $display("Test 8: Power PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL c=%0d", c);
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
