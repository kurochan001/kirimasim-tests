/*
:name: test_for_loop_bitsel_accumulate
:description: Bit-select and part-select writes in the body of a for loop change the variable of the enclosing block (IEEE 1800-2023 Section 12.7.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.1 11.5.1 9.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_for_loop_bitsel_accumulate.expected
*/
// IEEE 1800-2023 §12.7.1: the body of a for loop runs in the scope of the block
// that contains the loop, apart from the loop variable and anything the body
// declares itself. A bit-select or part-select write (11.5.1) in the body to a
// variable of the enclosing block (9.3.1) changes that variable, so the writes
// of all iterations add up.

module test_for_loop_bitsel_accumulate;
    initial begin
        bit [7:0] seen;
        bit [15:0] seen16;
        int       errors;
        errors = 0;
        seen   = 8'h00;
        // a bit-select write in each of 4 iterations, with a variable of the body
        for (int i = 0; i < 4; i++) begin
            int idx;
            idx = i * 2;
            seen[idx] = 1'b1;
        end
        if (seen !== 8'h55) begin
            $display("FAIL bit-select accumulation: seen=0x%02h expected 0x55", seen);
            errors++;
        end else begin
            $display("PASS bit-select accumulation: seen=0x55");
        end
        // every bit of the byte
        seen = 8'h00;
        for (int i = 0; i < 8; i++) begin
            seen[i] = 1'b1;
        end
        if (seen !== 8'hFF) begin
            $display("FAIL full 8-bit accumulation: seen=0x%02h expected 0xFF", seen);
            errors++;
        end else begin
            $display("PASS full 8-bit accumulation: seen=0xFF");
        end
        // indexed part-selects
        seen16 = 16'h0000;
        for (int i = 0; i < 4; i++) begin
            seen16[i*4 +: 4] = 4'hA;
        end
        if (seen16 !== 16'hAAAA) begin
            $display("FAIL part-select accumulation: seen16=0x%04h expected 0xAAAA", seen16);
            errors++;
        end else begin
            $display("PASS part-select accumulation: seen16=0xAAAA");
        end
        // the index comes from an array element
        begin
            bit [7:0] cycle_seen;
            static int picks[8] = '{3, 7, 1, 5, 0, 2, 6, 4};
            cycle_seen = 8'h00;
            for (int i = 0; i < 8; i++) begin
                cycle_seen[picks[i]] = 1'b1;
            end
            if (cycle_seen !== 8'hFF) begin
                $display("FAIL indexed accumulation: cycle_seen=0x%02h expected 0xFF", cycle_seen);
                errors++;
            end else begin
                $display("PASS indexed accumulation: cycle_seen=0xFF");
            end
        end
        if (errors == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED: %0d error(s)", errors);
        end
    end
endmodule
