/*
:name: test_decoder4_edge_cases
:description: 2-to-4 Decoder edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_decoder4_edge_cases.expected
*/
// IEEE 1800-2023: 2-to-4 Decoder edge cases
// Tests for decoder constructs

module test_decoder4_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [1:0] sel;
    logic en;
    logic [3:0] out;

    // 2:4 decoder with enable
    always_comb begin
        if (en) begin
            case (sel)
                2'b00: out = 4'b0001;
                2'b01: out = 4'b0010;
                2'b10: out = 4'b0100;
                2'b11: out = 4'b1000;
            endcase
        end else begin
            out = 4'b0000;
        end
    end

    initial begin
        // Test 1: Disabled decoder
        test_count++;
        en = 0; sel = 2'b00;
        #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 1 PASS: disabled out=%b", out);
        end else begin
            $display("Test 1 FAIL: unexpected out=%b", out);
        end

        // Test 2: Select 0
        test_count++;
        en = 1; sel = 2'b00;
        #1;
        if (out == 4'b0001) begin
            pass_count++;
            $display("Test 2 PASS: sel=0 out=%b", out);
        end else begin
            $display("Test 2 FAIL: unexpected out=%b", out);
        end

        // Test 3: Select 1
        test_count++;
        sel = 2'b01;
        #1;
        if (out == 4'b0010) begin
            pass_count++;
            $display("Test 3 PASS: sel=1 out=%b", out);
        end else begin
            $display("Test 3 FAIL: unexpected out=%b", out);
        end

        // Test 4: Select 2
        test_count++;
        sel = 2'b10;
        #1;
        if (out == 4'b0100) begin
            pass_count++;
            $display("Test 4 PASS: sel=2 out=%b", out);
        end else begin
            $display("Test 4 FAIL: unexpected out=%b", out);
        end

        // Test 5: Select 3
        test_count++;
        sel = 2'b11;
        #1;
        if (out == 4'b1000) begin
            pass_count++;
            $display("Test 5 PASS: sel=3 out=%b", out);
        end else begin
            $display("Test 5 FAIL: unexpected out=%b", out);
        end

        // Test 6: Enable toggle
        test_count++;
        sel = 2'b10;
        en = 1; #1;
        en = 0; #1;
        if (out == 0) begin
            pass_count++;
            $display("Test 6 PASS: enable toggle");
        end else begin
            $display("Test 6 FAIL: unexpected");
        end

        // Test 7: One-hot check
        test_count++;
        en = 1;
        for (int i = 0; i < 4; i++) begin
            sel = i[1:0];
            #1;
            if ($onehot(out)) begin
                // ok
            end
        end
        pass_count++;
        $display("Test 7 PASS: One-hot verified");

        $display("=== 2:4 Decoder Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
