/*
:name: test_mux_edge_cases
:description: A 4-to-1 multiplexer from a case statement in always_comb, and the conditional operator
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mux_edge_cases.expected
*/
// IEEE 1800-2023 §11.5: MUX edge cases
// Tests for multiplexer constructs

module test_mux_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] a, b, c, d;
    logic [1:0] sel;
    logic [7:0] out;

    // 4:1 mux using case
    always_comb begin
        case (sel)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            2'b11: out = d;
            default: out = 8'hXX;
        endcase
    end

    initial begin
        a = 8'hAA;
        b = 8'hBB;
        c = 8'hCC;
        d = 8'hDD;
        sel = 0;
        #1;

        // Test 1: Select a
        test_count++;
        sel = 2'b00;
        #1;
        if (out == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: sel=00 out=%h", out);
        end else begin
            $display("Test 1 FAIL: unexpected = %h", out);
        end

        // Test 2: Select b
        test_count++;
        sel = 2'b01;
        #1;
        if (out == 8'hBB) begin
            pass_count++;
            $display("Test 2 PASS: sel=01 out=%h", out);
        end else begin
            $display("Test 2 FAIL: unexpected = %h", out);
        end

        // Test 3: Select c
        test_count++;
        sel = 2'b10;
        #1;
        if (out == 8'hCC) begin
            pass_count++;
            $display("Test 3 PASS: sel=10 out=%h", out);
        end else begin
            $display("Test 3 FAIL: unexpected = %h", out);
        end

        // Test 4: Select d
        test_count++;
        sel = 2'b11;
        #1;
        if (out == 8'hDD) begin
            pass_count++;
            $display("Test 4 PASS: sel=11 out=%h", out);
        end else begin
            $display("Test 4 FAIL: unexpected = %h", out);
        end

        // Test 5: Change input while selected
        test_count++;
        a = 8'h11;
        sel = 2'b00;
        #1;
        if (out == 8'h11) begin
            pass_count++;
            $display("Test 5 PASS: Changed a = %h", out);
        end else begin
            $display("Test 5 FAIL: unexpected = %h", out);
        end

        // Test 6: Ternary mux
        test_count++;
        begin
            static logic s = 1;
            static logic [7:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = s ? 8'hFF : 8'h00;
            if (result == 8'hFF) begin
                pass_count++;
                $display("Test 6 PASS: Ternary = %h", result);
            end else begin
                $display("Test 6 FAIL: Ternary unexpected = %h", result);
            end
        end

        // Test 7: Ternary mux (false)
        test_count++;
        begin
            static logic s = 0;
            static logic [7:0] result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = s ? 8'hFF : 8'h00;
            if (result == 8'h00) begin
                pass_count++;
                $display("Test 7 PASS: Ternary = %h", result);
            end else begin
                $display("Test 7 FAIL: Ternary unexpected = %h", result);
            end
        end

        // Test 8: Cycle through all
        test_count++;
        begin
            static logic [7:0] exp_out[4] = '{8'h11, 8'hBB, 8'hCC, 8'hDD};
            static int bad = 0;
            for (int i = 0; i < 4; i++) begin
                sel = i[1:0];
                #1;
                if (out !== exp_out[i]) bad++;
            end
            if (bad == 0) begin
                pass_count++;
                $display("Test 8 PASS: Cycle complete");
            end else begin
                $display("Test 8 FAIL: %0d selections wrong", bad);
            end
        end

        $display("=== MUX Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
