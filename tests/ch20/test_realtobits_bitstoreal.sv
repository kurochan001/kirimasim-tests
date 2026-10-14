/*
:name: test_realtobits_bitstoreal
:description: $realtobits, $bitstoreal, $shortrealtobits, $bitstoshortreal, $itor, $rtoi
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_realtobits_bitstoreal.expected
*/
// $realtobits, $bitstoreal, $shortrealtobits, $bitstoshortreal, $itor, $rtoi
module test_realtobits_bitstoreal;
    int pass_count = 0;
    int test_count = 15;

    initial begin
        // T1: $realtobits(1.0) = 64'h3FF0000000000000
        begin
            static longint unsigned v = $realtobits(1.0);
            if (v == 64'h3FF0000000000000) begin
                $display("T1: PASS - $realtobits(1.0) = %h", v);
                pass_count++;
            end else
                $display("T1: FAIL - $realtobits(1.0) = %h (expected 3FF0000000000000)", v);
        end

        // T2: $bitstoreal(64'h3FF0000000000000) = 1.0 (round-trip)
        begin
            static real v = $bitstoreal(64'h3FF0000000000000);
            if (v == 1.0) begin
                $display("T2: PASS - $bitstoreal(3FF0...) = %f", v);
                pass_count++;
            end else
                $display("T2: FAIL - $bitstoreal(3FF0...) = %f (expected 1.0)", v);
        end

        // T3: $realtobits(0.0) = 64'h0
        begin
            static longint unsigned v = $realtobits(0.0);
            if (v == 64'h0) begin
                $display("T3: PASS - $realtobits(0.0) = %h", v);
                pass_count++;
            end else
                $display("T3: FAIL - $realtobits(0.0) = %h (expected 0)", v);
        end

        // T4: $bitstoreal(64'h0) = 0.0
        begin
            static real v = $bitstoreal(64'h0);
            if (v == 0.0) begin
                $display("T4: PASS - $bitstoreal(0) = %f", v);
                pass_count++;
            end else
                $display("T4: FAIL - $bitstoreal(0) = %f (expected 0.0)", v);
        end

        // T5: $realtobits(-1.0) — sign bit set
        begin
            static longint unsigned v = $realtobits(-1.0);
            if (v == 64'hBFF0000000000000) begin
                $display("T5: PASS - $realtobits(-1.0) = %h", v);
                pass_count++;
            end else
                $display("T5: FAIL - $realtobits(-1.0) = %h (expected BFF0000000000000)", v);
        end

        // T6: $bitstoreal($realtobits(3.14)) round-trip precision
        begin
            static real original = 3.14;
            static real v;
            // Assigned here so the result does not depend on the order of static initializers.
            v = $bitstoreal($realtobits(original));
            if (v == original) begin
                $display("T6: PASS - round-trip 3.14 = %f", v);
                pass_count++;
            end else
                $display("T6: FAIL - round-trip 3.14 = %f (expected 3.14)", v);
        end

        // T7: $shortrealtobits(1.0) = 32'h3F800000
        begin
            static int unsigned v = $shortrealtobits(1.0);
            if (v == 32'h3F800000) begin
                $display("T7: PASS - $shortrealtobits(1.0) = %h", v);
                pass_count++;
            end else
                $display("T7: FAIL - $shortrealtobits(1.0) = %h (expected 3F800000)", v);
        end

        // T8: $bitstoshortreal(32'h3F800000) = 1.0
        begin
            static shortreal v = $bitstoshortreal(32'h3F800000);
            if (v == 1.0) begin
                $display("T8: PASS - $bitstoshortreal(3F800000) = %f", v);
                pass_count++;
            end else
                $display("T8: FAIL - $bitstoshortreal(3F800000) = %f (expected 1.0)", v);
        end

        // T9: $shortrealtobits(0.0) = 32'h0
        begin
            static int unsigned v = $shortrealtobits(0.0);
            if (v == 32'h0) begin
                $display("T9: PASS - $shortrealtobits(0.0) = %h", v);
                pass_count++;
            end else
                $display("T9: FAIL - $shortrealtobits(0.0) = %h (expected 0)", v);
        end

        // T10: $bitstoshortreal(32'h0) = 0.0
        begin
            static shortreal v = $bitstoshortreal(32'h0);
            if (v == 0.0) begin
                $display("T10: PASS - $bitstoshortreal(0) = %f", v);
                pass_count++;
            end else
                $display("T10: FAIL - $bitstoshortreal(0) = %f (expected 0.0)", v);
        end

        // T11: $shortrealtobits(-1.0) = 32'hBF800000
        begin
            static int unsigned v = $shortrealtobits(-1.0);
            if (v == 32'hBF800000) begin
                $display("T11: PASS - $shortrealtobits(-1.0) = %h", v);
                pass_count++;
            end else
                $display("T11: FAIL - $shortrealtobits(-1.0) = %h (expected BF800000)", v);
        end

        // T12: $bitstoshortreal($shortrealtobits(2.5)) round-trip
        begin
            static shortreal original = 2.5;
            static shortreal v;
            // Assigned here so the result does not depend on the order of static initializers.
            v = $bitstoshortreal($shortrealtobits(original));
            if (v == original) begin
                $display("T12: PASS - shortreal round-trip 2.5 = %f", v);
                pass_count++;
            end else
                $display("T12: FAIL - shortreal round-trip 2.5 = %f", v);
        end

        // T13: $realtobits large value (1.0e100) — no crash
        begin
            static longint unsigned v = $realtobits(1.0e100);
            // Just confirm it doesn't crash and returns non-zero
            if (v != 0) begin
                $display("T13: PASS - $realtobits(1.0e100) = %h", v);
                pass_count++;
            end else
                $display("T13: FAIL - $realtobits(1.0e100) = 0");
        end

        // T14: $bitstoreal special bit pattern (NaN candidate)
        begin
            // 0x7FF8000000000000 is a quiet NaN in IEEE 754
            static real v = $bitstoreal(64'h7FF8000000000000);
            // NaN != NaN by IEEE 754 definition
            if (v != v) begin
                $display("T14: PASS - $bitstoreal(NaN pattern) is NaN");
                pass_count++;
            end else begin
                $display("T14: FAIL - $bitstoreal(NaN pattern) is not NaN");
            end
        end

        // T15: $itor(42) + $rtoi(42.7) — integer/real conversion
        begin
            static real r = $itor(42);
            static int i = $rtoi(42.7);
            // $rtoi truncates toward zero (20.5)
            if (r == 42.0 && i == 42) begin
                $display("T15: PASS - $itor(42)=%f, $rtoi(42.7)=%0d", r, i);
                pass_count++;
            end else
                $display("T15: FAIL - $itor(42)=%f, $rtoi(42.7)=%0d", r, i);
        end

        // Summary
        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS");
        else
            $display("FAIL");
    end
endmodule
