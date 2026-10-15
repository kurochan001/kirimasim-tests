/*
:name: test_unique_priority_2
:description: Unique/Priority Case Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3 12.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_priority_2.expected
*/
// IEEE 1800-2023 Section 12.5.3 - Unique/Priority Case Tests
// Tests: unique case, priority case, unique if, priority if

module test_unique_priority_2;
    int pass_count = 0;
    int fail_count = 0;

    logic [1:0] sel;
    logic [7:0] out;
    logic a, b, c;

    initial begin
        $display("=== IEEE 1800-2023 Unique/Priority Tests ===");

        // Test 1: Unique case
        $display("Test 1: Unique case");
        sel = 2'b00;
        unique case (sel)
            2'b00: out = 8'h11;
            2'b01: out = 8'h22;
            2'b10: out = 8'h33;
            2'b11: out = 8'h44;
        endcase
        if (out == 8'h11) begin
            $display("Test 1 PASS: sel=%b out=%h", sel, out);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", out);
            fail_count++;
        end

        // Test 2: Unique case another value
        $display("Test 2: Unique case value 01");
        sel = 2'b01;
        unique case (sel)
            2'b00: out = 8'h11;
            2'b01: out = 8'h22;
            2'b10: out = 8'h33;
            2'b11: out = 8'h44;
        endcase
        if (out == 8'h22) begin
            $display("Test 2 PASS: sel=%b out=%h", sel, out);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", out);
            fail_count++;
        end

        // Test 3: Priority case
        $display("Test 3: Priority case");
        sel = 2'b10;
        priority case (sel)
            2'b00: out = 8'hAA;
            2'b01: out = 8'hBB;
            2'b10: out = 8'hCC;
            2'b11: out = 8'hDD;
        endcase
        if (out == 8'hCC) begin
            $display("Test 3 PASS: sel=%b out=%h", sel, out);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", out);
            fail_count++;
        end

        // Test 4: Priority case last value
        $display("Test 4: Priority case value 11");
        sel = 2'b11;
        priority case (sel)
            2'b00: out = 8'hAA;
            2'b01: out = 8'hBB;
            2'b10: out = 8'hCC;
            2'b11: out = 8'hDD;
        endcase
        if (out == 8'hDD) begin
            $display("Test 4 PASS: sel=%b out=%h", sel, out);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", out);
            fail_count++;
        end

        // Test 5: Unique if
        $display("Test 5: Unique if");
        a = 1; b = 0; c = 0;
        unique if (a) out = 8'h10;
        else if (b) out = 8'h20;
        else if (c) out = 8'h30;
        else out = 8'h00;
        if (out == 8'h10) begin
            $display("Test 5 PASS: unique if a=1, out=%h", out);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", out);
            fail_count++;
        end

        // Test 6: Unique if second branch
        $display("Test 6: Unique if second branch");
        a = 0; b = 1; c = 0;
        unique if (a) out = 8'h10;
        else if (b) out = 8'h20;
        else if (c) out = 8'h30;
        else out = 8'h00;
        if (out == 8'h20) begin
            $display("Test 6 PASS: unique if b=1, out=%h", out);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", out);
            fail_count++;
        end

        // Test 7: Priority if
        $display("Test 7: Priority if");
        a = 0; b = 0; c = 1;
        priority if (a) out = 8'h01;
        else if (b) out = 8'h02;
        else if (c) out = 8'h03;
        else out = 8'hFF;
        if (out == 8'h03) begin
            $display("Test 7 PASS: priority if c=1, out=%h", out);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", out);
            fail_count++;
        end

        // Test 8: Priority if else
        $display("Test 8: Priority if else branch");
        a = 0; b = 0; c = 0;
        priority if (a) out = 8'h01;
        else if (b) out = 8'h02;
        else if (c) out = 8'h03;
        else out = 8'hFF;
        if (out == 8'hFF) begin
            $display("Test 8 PASS: priority if else, out=%h", out);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", out);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
