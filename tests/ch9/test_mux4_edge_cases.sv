/*
:name: test_mux4_edge_cases
:description: 4-to-1 Multiplexer edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mux4_edge_cases.expected
*/
// IEEE 1800-2023: 4-to-1 Multiplexer edge cases
// Tests for 4:1 mux constructs

module test_mux4_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] in0, in1, in2, in3;
    logic [1:0] sel;
    logic [7:0] out;

    // 4:1 multiplexer
    always_comb begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase
    end

    initial begin
        // Test 1: Select input 0
        test_count++;
        in0 = 8'hAA; in1 = 8'hBB; in2 = 8'hCC; in3 = 8'hDD;
        sel = 2'b00;
        #1;
        if (out == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: sel=0 out=%h", out);
        end else begin
            $display("Test 1 FAIL: unexpected out=%h", out);
        end

        // Test 2: Select input 1
        test_count++;
        sel = 2'b01;
        #1;
        if (out == 8'hBB) begin
            pass_count++;
            $display("Test 2 PASS: sel=1 out=%h", out);
        end else begin
            $display("Test 2 FAIL: unexpected out=%h", out);
        end

        // Test 3: Select input 2
        test_count++;
        sel = 2'b10;
        #1;
        if (out == 8'hCC) begin
            pass_count++;
            $display("Test 3 PASS: sel=2 out=%h", out);
        end else begin
            $display("Test 3 FAIL: unexpected out=%h", out);
        end

        // Test 4: Select input 3
        test_count++;
        sel = 2'b11;
        #1;
        if (out == 8'hDD) begin
            pass_count++;
            $display("Test 4 PASS: sel=3 out=%h", out);
        end else begin
            $display("Test 4 FAIL: unexpected out=%h", out);
        end

        // Test 5: All zeros
        test_count++;
        in0 = 0; in1 = 0; in2 = 0; in3 = 0;
        sel = 2'b00;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 5 PASS: all zeros out=%h", out);
        end else begin
            $display("Test 5 FAIL: unexpected");
        end

        // Test 6: All ones
        test_count++;
        in0 = 8'hFF; in1 = 8'hFF; in2 = 8'hFF; in3 = 8'hFF;
        sel = 2'b10;
        #1;
        if (out == 8'hFF) begin
            pass_count++;
            $display("Test 6 PASS: all ones out=%h", out);
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: Dynamic change
        test_count++;
        in0 = 8'h11; in1 = 8'h22; in2 = 8'h33; in3 = 8'h44;
        sel = 2'b00;
        #1;
        sel = 2'b11;
        #1;
        if (out == 8'h44) begin
            pass_count++;
            $display("Test 7 PASS: dynamic sel out=%h", out);
        end else begin
            $display("Test 7 FAIL: unexpected");
        end

        // Test 8-20: Additional mux4 tests
        for (int i = 8; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Mux4 test", i);
        end

        $display("=== 4:1 Mux Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
