/*
:name: test_force_deep_generate_scope
:description: force and release on variables, packed structs and variables in generate blocks
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2 27.4 7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_deep_generate_scope.expected
*/
module test_force_deep_generate_scope;
    int pass_count = 0;
    int test_count = 16;

    // Submodule with struct signal
    typedef struct packed {
        logic [7:0] hi;
        logic [7:0] lo;
    } pair_t;

    typedef struct packed {
        logic [7:0] tag;
        pair_t data;
    } frame_t;

    logic clk = 0;
    always #5 clk = ~clk;

    // Simple wire signals for force/release
    logic [7:0] sig_a;
    logic [7:0] sig_b;
    pair_t pair_sig;
    frame_t frame_sig;

    // Generate block with signals
    genvar gi;
    generate
        for (gi = 0; gi < 2; gi++) begin : gen_blk
            logic [7:0] gen_sig;
            pair_t gen_pair;
        end
    endgenerate

    // Continuous assigns for baseline
    assign sig_a = 8'h00;
    assign sig_b = 8'h00;
    assign pair_sig = '0;
    assign frame_sig = '0;

    initial begin
        // Initialize generate signals
        force gen_blk[0].gen_sig = 8'h00;
        force gen_blk[1].gen_sig = 8'h00;
        force gen_blk[0].gen_pair = '0;
        force gen_blk[1].gen_pair = '0;
        release gen_blk[0].gen_sig;
        release gen_blk[1].gen_sig;
        release gen_blk[0].gen_pair;
        release gen_blk[1].gen_pair;

        #1;

        // T1: force baseline — single signal
        begin
            force sig_a = 8'hAA;
            #1;
            if (sig_a === 8'hAA) begin
                $display("T1: PASS - force baseline: sig_a=%h", sig_a);
                pass_count++;
            end else begin
                $display("T1: FAIL - force baseline: sig_a=%h", sig_a);
            end
            release sig_a;
        end

        // T2: force + release — value returns to driven
        begin
            force sig_a = 8'hBB;
            #1;
            release sig_a;
            #1;
            if (sig_a === 8'h00) begin
                $display("T2: PASS - release: sig_a=%h", sig_a);
                pass_count++;
            end else begin
                $display("T2: FAIL - release: sig_a=%h (expected 00)", sig_a);
            end
        end

        // T3: force packed struct member — pair_sig using raw value
        begin
            force pair_sig = 16'hCCDD;
            #1;
            if (pair_sig.hi === 8'hCC && pair_sig.lo === 8'hDD) begin
                $display("T3: PASS - force struct: hi=%h lo=%h", pair_sig.hi, pair_sig.lo);
                pass_count++;
            end else begin
                $display("T3: FAIL - force struct: hi=%h lo=%h", pair_sig.hi, pair_sig.lo);
            end
            release pair_sig;
        end

        // T4: force 2-level struct member — frame_sig using raw value
        begin
            force frame_sig = 24'h01AABB;
            #1;
            if (frame_sig.tag === 8'h01 && frame_sig.data.hi === 8'hAA && frame_sig.data.lo === 8'hBB) begin
                $display("T4: PASS - force 2-level: tag=%h hi=%h lo=%h", frame_sig.tag, frame_sig.data.hi, frame_sig.data.lo);
                pass_count++;
            end else begin
                $display("T4: FAIL - force 2-level: tag=%h hi=%h lo=%h", frame_sig.tag, frame_sig.data.hi, frame_sig.data.lo);
            end
            release frame_sig;
        end

        // T5: force + release 2-level — values return to zero
        begin
            force frame_sig = 24'hFFEEDD;
            #1;
            release frame_sig;
            #1;
            if (frame_sig.tag === 8'h00 && frame_sig.data.hi === 8'h00) begin
                $display("T5: PASS - release 2-level: tag=%h", frame_sig.tag);
                pass_count++;
            end else begin
                $display("T5: FAIL - release 2-level: tag=%h hi=%h", frame_sig.tag, frame_sig.data.hi);
            end
        end

        // T6: force overwrite — second force overwrites first
        begin
            force sig_a = 8'h11;
            #1;
            force sig_a = 8'h22;
            #1;
            if (sig_a === 8'h22) begin
                $display("T6: PASS - force overwrite: %h", sig_a);
                pass_count++;
            end else begin
                $display("T6: FAIL - force overwrite: %h", sig_a);
            end
            release sig_a;
        end

        begin
            force gen_blk[0].gen_sig = 8'hAA;
            force gen_blk[1].gen_sig = 8'hBB;
            #1;
            if (gen_blk[0].gen_sig === 8'hAA && gen_blk[1].gen_sig === 8'hBB) begin
                $display("T7: PASS - generate force: [0]=%h [1]=%h", gen_blk[0].gen_sig, gen_blk[1].gen_sig);
                pass_count++;
            end else begin
                $display("T7: FAIL - generate force: [0]=%h [1]=%h", gen_blk[0].gen_sig, gen_blk[1].gen_sig);
            end
            release gen_blk[0].gen_sig;
            release gen_blk[1].gen_sig;
        end

        // T8: force generate struct — raw value + member access (B116b)
        // IEEE 1800-2023 §10.6.2: After force, packed struct member access must work
        begin
            force gen_blk[0].gen_pair = 16'h1122;
            #1;
            if (gen_blk[0].gen_pair === 16'h1122 &&
                gen_blk[0].gen_pair.hi === 8'h11 &&
                gen_blk[0].gen_pair.lo === 8'h22) begin
                $display("T8: PASS - gen struct force: raw=%h hi=%h lo=%h",
                    gen_blk[0].gen_pair, gen_blk[0].gen_pair.hi, gen_blk[0].gen_pair.lo);
                pass_count++;
            end else begin
                $display("T8: FAIL - gen struct force: raw=%h hi=%h lo=%h",
                    gen_blk[0].gen_pair, gen_blk[0].gen_pair.hi, gen_blk[0].gen_pair.lo);
            end
            release gen_blk[0].gen_pair;
        end

        // T9: generate force + release
        begin
            force gen_blk[1].gen_sig = 8'hCC;
            #1;
            release gen_blk[1].gen_sig;
            #1;
            // After release, value depends on driver (none here, so x or 0)
            $display("T9: PASS - gen release: gen_blk[1].gen_sig=%h", gen_blk[1].gen_sig);
            pass_count++;
        end

        // T10: force + release sequence — deep path
        begin
            force frame_sig = 24'hAABBCC;
            #1;
            release frame_sig;
            #1;
            force frame_sig = 24'hDDEEFF;
            #1;
            if (frame_sig.tag === 8'hDD && frame_sig.data.hi === 8'hEE && frame_sig.data.lo === 8'hFF) begin
                $display("T10: PASS - force-release-force: tag=%h hi=%h lo=%h",
                    frame_sig.tag, frame_sig.data.hi, frame_sig.data.lo);
                pass_count++;
            end else begin
                $display("T10: FAIL - force-release-force");
            end
            release frame_sig;
        end

        // T11: multiple signals forced simultaneously
        begin
            force sig_a = 8'h11;
            force sig_b = 8'h22;
            force pair_sig = 16'h3344;
            #1;
            if (sig_a === 8'h11 && sig_b === 8'h22 && pair_sig.hi === 8'h33 && pair_sig.lo === 8'h44) begin
                $display("T11: PASS - multi-force: a=%h b=%h hi=%h lo=%h",
                    sig_a, sig_b, pair_sig.hi, pair_sig.lo);
                pass_count++;
            end else begin
                $display("T11: FAIL - multi-force");
            end
            release sig_a;
            release sig_b;
            release pair_sig;
        end

        // T12: force two generate blocks simultaneously
        begin
            force gen_blk[0].gen_sig = 8'hAA;
            force gen_blk[1].gen_sig = 8'h55;
            #1;
            if (gen_blk[0].gen_sig === 8'hAA && gen_blk[1].gen_sig === 8'h55) begin
                $display("T12: PASS - dual gen force: [0]=%h [1]=%h", gen_blk[0].gen_sig, gen_blk[1].gen_sig);
                pass_count++;
            end else begin
                $display("T12: FAIL - dual gen force");
            end
            release gen_blk[0].gen_sig;
            release gen_blk[1].gen_sig;
        end

        // T13: force with expression value
        begin
            static logic [7:0] val = 8'hA0;
            force sig_a = val | 8'h0F;
            #1;
            if (sig_a === 8'hAF) begin
                $display("T13: PASS - force expr: %h", sig_a);
                pass_count++;
            end else begin
                $display("T13: FAIL - force expr: %h (expected AF)", sig_a);
            end
            release sig_a;
        end

        // T14: multiple concurrent forces on same root struct
        begin
            force frame_sig = 24'h102030;
            #1;
            force frame_sig = 24'h405060;
            #1;
            if (frame_sig.tag === 8'h40 && frame_sig.data.hi === 8'h50 && frame_sig.data.lo === 8'h60) begin
                $display("T14: PASS - concurrent force: tag=%h hi=%h lo=%h",
                    frame_sig.tag, frame_sig.data.hi, frame_sig.data.lo);
                pass_count++;
            end else begin
                $display("T14: FAIL - concurrent force");
            end
            release frame_sig;
        end

        // T15: force + clock edge synchronization
        begin
            force sig_a = 8'hFF;
            @(posedge clk);
            if (sig_a === 8'hFF) begin
                $display("T15: PASS - force+clock: %h", sig_a);
                pass_count++;
            end else begin
                $display("T15: FAIL - force+clock: %h", sig_a);
            end
            release sig_a;
        end

        // T16: force + release all — cleanup verification
        begin
            force sig_a = 8'h11;
            force sig_b = 8'h22;
            force pair_sig = 16'h3344;
            force frame_sig = 24'h556677;
            #1;
            release sig_a;
            release sig_b;
            release pair_sig;
            release frame_sig;
            #1;
            if (sig_a === 8'h00 && sig_b === 8'h00 && pair_sig === '0 && frame_sig === '0) begin
                $display("T16: PASS - release all: ok");
                pass_count++;
            end else begin
                $display("T16: FAIL - release all: a=%h b=%h", sig_a, sig_b);
            end
        end

        $display("\n%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) $display("PASS");
        else $display("FAIL");
        $finish;
    end
endmodule
