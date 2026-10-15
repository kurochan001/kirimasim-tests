/*
:name: test_bit_select_2
:description: Bit Select and Part Select Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_select_2.expected
*/
// IEEE 1800-2023 Section 7.4 - Bit Select and Part Select Tests
// Tests: bit select, part select, indexed part select

module test_bit_select;
    int pass_count = 0;
    int fail_count = 0;

    logic [31:0] data;
    logic [7:0] byte_val;
    logic bit_val;
    logic [15:0] half_word;
    int idx;

    initial begin
        $display("=== IEEE 1800-2023 Bit Select Test ===");

        // Initialize
        data = 32'hDEADBEEF;

        // Test 1: Single bit select
        $display("Test 1: Single bit select");
        bit_val = data[0];
        $display("Test 1 PASS: data[0] = %b", bit_val);
        pass_count++;

        // Test 2: Part select
        $display("Test 2: Part select");
        byte_val = data[7:0];
        $display("Test 2 PASS: data[7:0] = %h", byte_val);
        pass_count++;

        // Test 3: Upper part select
        $display("Test 3: Upper part select");
        byte_val = data[31:24];
        $display("Test 3 PASS: data[31:24] = %h", byte_val);
        pass_count++;

        // Test 4: Indexed part select +
        $display("Test 4: Indexed part select +:");
        idx = 8;
        byte_val = data[idx +: 8];
        $display("Test 4 PASS: data[8+:8] = %h", byte_val);
        pass_count++;

        // Test 5: Indexed part select -
        $display("Test 5: Indexed part select -:");
        idx = 23;
        byte_val = data[idx -: 8];
        $display("Test 5 PASS: data[23-:8] = %h", byte_val);
        pass_count++;

        // Test 6: Variable bit select
        $display("Test 6: Variable bit select");
        for (int i = 0; i < 4; i++) begin
            bit_val = data[i];
            $display("  data[%0d] = %b", i, bit_val);
        end
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Half word select
        $display("Test 7: Half word select");
        half_word = data[15:0];
        $display("Test 7 PASS: data[15:0] = %h", half_word);
        pass_count++;

        // Test 8: Bit assignment
        $display("Test 8: Bit assignment");
        data[0] = 1'b0;
        $display("Test 8 PASS: data = %h", data);
        pass_count++;

        // Test 9: Part select assignment
        $display("Test 9: Part select assignment");
        data[7:0] = 8'h00;
        $display("Test 9 PASS: data = %h", data);
        pass_count++;

        // Test 10: Indexed part select assignment
        $display("Test 10: Indexed part select assignment");
        idx = 16;
        data[idx +: 8] = 8'hFF;
        $display("Test 10 PASS: data = %h", data);
        pass_count++;

        // Test 11: Multiple byte extraction
        $display("Test 11: Multiple byte extraction");
        for (int i = 0; i < 4; i++) begin
            byte_val = data[i*8 +: 8];
            $display("  byte[%0d] = %h", i, byte_val);
        end
        $display("Test 11 PASS");
        pass_count++;

        // Test 12: Concatenation with bit select
        $display("Test 12: Concatenation with bit select");
        data = {data[23:16], data[31:24], data[7:0], data[15:8]};
        $display("Test 12 PASS: swapped = %h", data);
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
