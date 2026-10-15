/*
:name: test_reduction_xz_propagation
:description: Reduction operators, 11.4.11: Conditional operator
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 11.4.12 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_reduction_xz_propagation.expected
*/
// IEEE 1800-2023 Section 11.4.12: Reduction operators, 11.4.11: Conditional operator
module test_reduction_xz_propagation;
    int pass_count = 0;
    int test_count = 17;

    initial begin
        // T1: &8'hFF = 1 - all bits AND
        begin
            logic r;
            r = &8'hFF;
            if (r === 1'b1) begin
                $display("T1: PASS - &8'hFF = %b", r);
                pass_count++;
            end else $display("T1: FAIL - &8'hFF = %b expected 1", r);
        end

        // T2: &8'h0F = 0 - partial AND
        begin
            logic r;
            r = &8'h0F;
            if (r === 1'b0) begin
                $display("T2: PASS - &8'h0F = %b", r);
                pass_count++;
            end else $display("T2: FAIL - &8'h0F = %b expected 0", r);
        end

        // T3: |8'h00 = 0 - all bits OR zero
        begin
            logic r;
            r = |8'h00;
            if (r === 1'b0) begin
                $display("T3: PASS - |8'h00 = %b", r);
                pass_count++;
            end else $display("T3: FAIL - |8'h00 = %b expected 0", r);
        end

        // T4: |8'h01 = 1 - OR non-zero
        begin
            logic r;
            r = |8'h01;
            if (r === 1'b1) begin
                $display("T4: PASS - |8'h01 = %b", r);
                pass_count++;
            end else $display("T4: FAIL - |8'h01 = %b expected 1", r);
        end

        // T5: ^8'hA5 - XOR reduction (parity)
        // A5 = 10100101 -> 4 ones -> even parity -> 0
        begin
            logic r;
            r = ^8'hA5;
            if (r === 1'b0) begin
                $display("T5: PASS - ^8'hA5 = %b (even parity)", r);
                pass_count++;
            end else $display("T5: FAIL - ^8'hA5 = %b expected 0", r);
        end

        // T6: ~&8'hFF = 0 - NAND
        begin
            logic r;
            r = ~&8'hFF;
            if (r === 1'b0) begin
                $display("T6: PASS - ~&8'hFF = %b", r);
                pass_count++;
            end else $display("T6: FAIL - ~&8'hFF = %b expected 0", r);
        end

        // T7: ~|8'h00 = 1 - NOR
        begin
            logic r;
            r = ~|8'h00;
            if (r === 1'b1) begin
                $display("T7: PASS - ~|8'h00 = %b", r);
                pass_count++;
            end else $display("T7: FAIL - ~|8'h00 = %b expected 1", r);
        end

        // T8: ~^8'hFF - XNOR reduction
        // FF = 11111111 -> 8 ones -> even parity ^=0 -> ~^ = 1
        begin
            logic r;
            r = ~^8'hFF;
            if (r === 1'b1) begin
                $display("T8: PASS - ~^8'hFF = %b", r);
                pass_count++;
            end else $display("T8: FAIL - ~^8'hFF = %b expected 1", r);
        end

        // T9: &4'b1x1x - X in AND -> x (unless there's a 0)
        // No 0 present, but x present -> result is x
        begin
            logic [3:0] val;
            logic r;
            val = 4'b1x1x;
            r = &val;
            if (r === 1'bx) begin
                $display("T9: PASS - &4'b1x1x = x");
                pass_count++;
            end else $display("T9: FAIL - &4'b1x1x = %b expected x", r);
        end

        // T10: |4'b0x00 - X in OR -> x (if no 1 present)
        // No 1, but x present -> result is x
        begin
            logic [3:0] val;
            logic r;
            val = 4'b0x00;
            r = |val;
            if (r === 1'bx) begin
                $display("T10: PASS - |4'b0x00 = x");
                pass_count++;
            end else $display("T10: FAIL - |4'b0x00 = %b expected x", r);
        end

        // T11: ^4'bx010 - X in XOR -> x
        begin
            logic [3:0] val;
            logic r;
            val = 4'bx010;
            r = ^val;
            if (r === 1'bx) begin
                $display("T11: PASS - ^4'bx010 = x");
                pass_count++;
            end else $display("T11: FAIL - ^4'bx010 = %b expected x", r);
        end

        // T12: &4'b1z11 - Z in AND -> x
        begin
            logic [3:0] val;
            logic r;
            val = 4'b1z11;
            r = &val;
            if (r === 1'bx) begin
                $display("T12: PASS - &4'b1z11 = x");
                pass_count++;
            end else $display("T12: FAIL - &4'b1z11 = %b expected x", r);
        end

        // T13: Ternary operator X condition: x ? a : b -> bitwise merge
        begin
            logic [7:0] result;
            logic cond;
            cond = 1'bx;
            result = cond ? 8'd10 : 8'd20;
            // IEEE 1800-2023 §11.4.11: bitwise merge when condition is x/z
            // 10 = 00001010, 20 = 00010100
            // Matching bits stay, differing bits become x
            // result = 000xxxx0
            if (result === 8'b000xxxx0) begin
                $display("T13: PASS - ternary x cond result=%b (bitwise merge)", result);
                pass_count++;
            end else $display("T13: FAIL - ternary x cond result=%b expected 000xxxx0", result);
        end

        // T14: Ternary operator Z condition: z ? a : b -> bitwise merge
        begin
            logic [7:0] result;
            logic cond;
            cond = 1'bz;
            result = cond ? 8'd10 : 8'd20;
            // Same bitwise merge behavior for z condition
            if (result === 8'b000xxxx0) begin
                $display("T14: PASS - ternary z cond result=%b (bitwise merge)", result);
                pass_count++;
            end else $display("T14: FAIL - ternary z cond result=%b expected 000xxxx0", result);
        end

        // T15: Ternary both same: x ? 5 : 5 = 5
        begin
            logic [7:0] result;
            logic cond;
            cond = 1'bx;
            result = cond ? 8'd5 : 8'd5;
            if (result === 8'd5) begin
                $display("T15: PASS - ternary x same val result=%0d", result);
                pass_count++;
            end else $display("T15: FAIL - result=%b expected 5", result);
        end

        // T16: |32'h0 large width
        begin
            logic r;
            r = |32'h00000000;
            if (r === 1'b0) begin
                $display("T16: PASS - |32'h0 = %b", r);
                pass_count++;
            end else $display("T16: FAIL - |32'h0 = %b expected 0", r);
        end

        // T17: ^1'b1 single bit reduction
        begin
            logic r;
            r = ^1'b1;
            if (r === 1'b1) begin
                $display("T17: PASS - ^1'b1 = %b", r);
                pass_count++;
            end else $display("T17: FAIL - ^1'b1 = %b expected 1", r);
        end

        // Summary
        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS");
        else
            $display("FAIL");
    end
endmodule
