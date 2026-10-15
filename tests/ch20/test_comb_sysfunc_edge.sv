/*
:name: test_comb_sysfunc_edge
:description: Test: System function edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.9 20.5 21.3.3 20.6.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_comb_sysfunc_edge.expected
*/
// Test: System function edge cases
// Verifies IEEE 1800-2023 §20 system functions with edge-case inputs
module test_comb_sysfunc_edge;
    int pass_count = 0;

    initial begin
        // T1: $clog2 edge cases
        begin
            if ($clog2(0) == 0 && $clog2(1) == 0 && $clog2(2) == 1 &&
                $clog2(7) == 3 && $clog2(8) == 3 && $clog2(9) == 4 &&
                $clog2(65536) == 16) begin
                $display("T1: PASS - $clog2 edge cases correct");
                pass_count++;
            end else
                $display("T1: FAIL - clog2: 0=%0d 1=%0d 2=%0d 7=%0d 8=%0d 9=%0d 65536=%0d",
                    $clog2(0), $clog2(1), $clog2(2), $clog2(7), $clog2(8), $clog2(9), $clog2(65536));
        end

        // T2: $countones with various patterns
        begin
            if ($countones(8'b00000000) == 0 &&
                $countones(8'b11111111) == 8 &&
                $countones(8'b10101010) == 4 &&
                $countones(8'b00000001) == 1) begin
                $display("T2: PASS - $countones patterns correct");
                pass_count++;
            end else
                $display("T2: FAIL");
        end

        // T3: $onehot
        begin
            if ($onehot(8'b00000001) == 1 &&
                $onehot(8'b10000000) == 1 &&
                $onehot(8'b00000000) == 0 &&
                $onehot(8'b00000011) == 0) begin
                $display("T3: PASS - $onehot correct");
                pass_count++;
            end else
                $display("T3: FAIL");
        end

        // T4: $onehot0
        begin
            if ($onehot0(8'b00000000) == 1 &&
                $onehot0(8'b00000001) == 1 &&
                $onehot0(8'b10000000) == 1 &&
                $onehot0(8'b00000011) == 0) begin
                $display("T4: PASS - $onehot0 correct");
                pass_count++;
            end else
                $display("T4: FAIL");
        end

        // T5: $isunknown
        begin
            static logic [7:0] clean = 8'hFF;
            static logic [7:0] with_x = 8'bxxxx0000;
            static logic [7:0] with_z = 8'b0000zzzz;
            if ($isunknown(clean) == 0 &&
                $isunknown(with_x) == 1 &&
                $isunknown(with_z) == 1) begin
                $display("T5: PASS - $isunknown detects X and Z");
                pass_count++;
            end else
                $display("T5: FAIL");
        end

        // T6: $signed and $unsigned
        begin
            static logic [7:0] val = 8'hFF;
            static int signed_val;
            static int unsigned_val;
            // Assigned here so the result does not depend on the order of static initializers.
            signed_val = $signed(val);
            unsigned_val = $unsigned(val);
            if (signed_val == -1 && unsigned_val == 255) begin
                $display("T6: PASS - $signed(FF)=%0d $unsigned(FF)=%0d", signed_val, unsigned_val);
                pass_count++;
            end else
                $display("T6: FAIL - signed=%0d unsigned=%0d", signed_val, unsigned_val);
        end

        // T7: $sformatf
        begin
            static string s = $sformatf("val=%0d hex=%h", 42, 8'hAB);
            if (s == "val=42 hex=ab") begin
                $display("T7: PASS - $sformatf: %s", s);
                pass_count++;
            end else
                $display("T7: FAIL - s=%s", s);
        end

        // T8: $bits on various types
        begin
            logic [15:0] a;
            logic [7:0] b;
            bit c;
            int d;
            if ($bits(a) == 16 && $bits(b) == 8 &&
                $bits(c) == 1 && $bits(d) == 32) begin
                $display("T8: PASS - $bits: 16,8,1,32");
                pass_count++;
            end else
                $display("T8: FAIL");
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 8)
            $display("PASS: test_comb_sysfunc_edge");
        else
            $display("FAIL: test_comb_sysfunc_edge (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
