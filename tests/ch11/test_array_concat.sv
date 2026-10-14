/*
:name: test_array_concat
:description: Array Concatenation Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_concat.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Array Concatenation Tests
module test_array_concat;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] a, b, result16;
        logic [15:0] wide;
        logic [3:0] nibble_h, nibble_l;

        $display("=== IEEE 1800-2023 Array Concatenation Tests ===");

        $display("Test 1: Simple concat");
        a = 8'hAB;
        b = 8'hCD;
        wide = {a, b};
        if (wide == 16'hABCD) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", wide); fail_count++; end

        $display("Test 2: Nibble concat");
        nibble_h = 4'hA;
        nibble_l = 4'hB;
        result16 = {nibble_h, nibble_l};
        if (result16 == 8'hAB) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", result16); fail_count++; end

        $display("Test 3: Replicate");
        a = 8'h0F;
        wide = {2{a}};
        if (wide == 16'h0F0F) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", wide); fail_count++; end

        $display("Test 4: Mixed concat");
        a = 8'hFF;
        wide = {4'h0, 4'h0, a};
        if (wide == 16'h00FF) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", wide); fail_count++; end

        $display("Test 5: Var concat");
        a = 8'hDE;
        b = 8'hAD;
        wide = {a, b};
        if (wide == 16'hDEAD) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", wide); fail_count++; end

        $display("Test 6: Concat to wide");
        nibble_h = 4'h1;
        nibble_l = 4'h2;
        wide = {nibble_h, nibble_l, nibble_h, nibble_l};
        if (wide == 16'h1212) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", wide); fail_count++; end

        $display("Test 7: Zero extend");
        a = 8'h12;
        wide = {8'h00, a};
        if (wide == 16'h0012) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", wide); fail_count++; end

        $display("Test 8: Replication 4x");
        nibble_h = 4'hF;
        wide = {4{nibble_h}};
        if (wide == 16'hFFFF) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", wide); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
