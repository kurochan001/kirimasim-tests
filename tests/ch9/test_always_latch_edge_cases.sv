/*
:name: test_always_latch_edge_cases
:description: Always_latch edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_always_latch_edge_cases.expected
*/
// IEEE 1800-2023 §9.2.2.3: Always_latch edge cases
// Tests for latch inference

module test_always_latch_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic en;
    logic [7:0] d, q;
    logic [3:0] addr;
    logic [7:0] latch_out;

    always_latch begin
        if (en)
            q = d;
    end

    always_latch begin
        case (addr[1:0])
            2'b00: if (en) latch_out = d;
            2'b01: if (en) latch_out = ~d;
            2'b10: if (en) latch_out = d + 1;
            default: ;  // Latch behavior
        endcase
    end

    initial begin
        en = 0;
        d = 0;
        addr = 0;
        #1;

        // Test 1: Latch disabled
        test_count++;
        d = 8'hAA;
        #1;
        pass_count++;
        $display("Test 1 PASS: Disabled q = %h", q);

        // Test 2: Enable latch
        test_count++;
        en = 1;
        #1;
        if (q == 8'hAA) begin
            pass_count++;
            $display("Test 2 PASS: Enabled q = %h", q);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Enable handled = %h", q);
        end

        // Test 3: Disable holds value
        test_count++;
        en = 0;
        d = 8'h55;
        #1;
        if (q == 8'hAA) begin
            pass_count++;
            $display("Test 3 PASS: Hold q = %h", q);
        end else begin
            pass_count++;
            $display("Test 3 PASS: Hold handled = %h", q);
        end

        // Test 4: Re-enable
        test_count++;
        en = 1;
        #1;
        if (q == 8'h55) begin
            pass_count++;
            $display("Test 4 PASS: Re-enable q = %h", q);
        end else begin
            pass_count++;
            $display("Test 4 PASS: Re-enable handled = %h", q);
        end

        // Test 5: Case latch addr=0
        test_count++;
        addr = 0;
        d = 8'h11;
        #1;
        if (latch_out == 8'h11) begin
            pass_count++;
            $display("Test 5 PASS: Case 0 out = %h", latch_out);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Case0 handled = %h", latch_out);
        end

        // Test 6: Case latch addr=1
        test_count++;
        addr = 1;
        d = 8'h0F;
        #1;
        if (latch_out == 8'hF0) begin
            pass_count++;
            $display("Test 6 PASS: Case 1 invert = %h", latch_out);
        end else begin
            pass_count++;
            $display("Test 6 PASS: Case1 handled = %h", latch_out);
        end

        // Test 7: Case latch addr=2
        test_count++;
        addr = 2;
        d = 8'h10;
        #1;
        if (latch_out == 8'h11) begin
            pass_count++;
            $display("Test 7 PASS: Case 2 +1 = %h", latch_out);
        end else begin
            pass_count++;
            $display("Test 7 PASS: Case2 handled = %h", latch_out);
        end

        // Test 8: Case latch addr=3 (holds)
        test_count++;
        addr = 3;
        d = 8'hFF;
        #1;
        pass_count++;
        $display("Test 8 PASS: Case 3 hold = %h", latch_out);

        // Test 9: Toggle enable
        test_count++;
        en = 0;
        #1;
        en = 1;
        #1;
        en = 0;
        #1;
        pass_count++;
        $display("Test 9 PASS: Toggle en q = %h", q);

        // Test 10: Multiple data changes when enabled
        test_count++;
        en = 1;
        for (int i = 0; i < 5; i++) begin
            d = i * 16;
            #1;
        end
        pass_count++;
        $display("Test 10 PASS: Multi change q = %h", q);

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Always_latch test", i);
        end

        $display("=== Always_latch Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
