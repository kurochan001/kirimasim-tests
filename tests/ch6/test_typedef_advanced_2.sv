/*
:name: test_typedef_advanced_2
:description: Typedef advanced tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_advanced_2.expected
*/
// IEEE 1800-2023 §6.18: Typedef advanced tests
// Tests for typedef, type aliases

module test_typedef_advanced_2;
    int pass_count = 0;
    int test_count = 0;

    // Simple typedefs
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    // Signed typedef
    typedef int signed_int_t;
    typedef shortint short_t;

    // Array typedef
    typedef logic [7:0] byte_array_t [0:3];

    // Struct typedef
    typedef struct {
        logic [7:0] data;
        logic valid;
    } packet_t;

    // Enum typedef
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RUN  = 2'b01,
        DONE = 2'b10
    } state_t;

    byte_t b;
    word_t w;
    dword_t d;
    signed_int_t si;
    short_t sh;
    byte_array_t ba;
    packet_t pkt;
    state_t st;

    initial begin
        // Test 1: byte_t
        test_count++;
        b = 8'hAB;
        if (b == 8'hAB) begin
            pass_count++;
            $display("Test 1 PASS: byte_t = %h", b);
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: word_t
        test_count++;
        w = 16'hDEAD;
        if (w == 16'hDEAD) begin
            pass_count++;
            $display("Test 2 PASS: word_t = %h", w);
        end else begin
            $display("Test 2 FAIL");
        end

        // Test 3: dword_t
        test_count++;
        d = 32'hCAFEBABE;
        if (d == 32'hCAFEBABE) begin
            pass_count++;
            $display("Test 3 PASS: dword_t = %h", d);
        end else begin
            $display("Test 3 FAIL");
        end

        // Test 4: signed_int_t
        test_count++;
        si = -100;
        if (si == -100) begin
            pass_count++;
            $display("Test 4 PASS: signed_int_t = %0d", si);
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: short_t
        test_count++;
        sh = 1000;
        if (sh == 1000) begin
            pass_count++;
            $display("Test 5 PASS: short_t = %0d", sh);
        end else begin
            $display("Test 5 FAIL");
        end

        // Test 6: byte_array_t
        test_count++;
        ba[0] = 8'h11;
        ba[1] = 8'h22;
        ba[2] = 8'h33;
        ba[3] = 8'h44;
        if (ba[0] == 8'h11 && ba[3] == 8'h44) begin
            pass_count++;
            $display("Test 6 PASS: byte_array_t[0]=%h [3]=%h", ba[0], ba[3]);
        end else begin
            $display("Test 6 FAIL");
        end

        // Test 7: packet_t data
        test_count++;
        pkt.data = 8'h55;
        pkt.valid = 1;
        if (pkt.data == 8'h55) begin
            pass_count++;
            $display("Test 7 PASS: packet_t.data = %h", pkt.data);
        end else begin
            $display("Test 7 FAIL");
        end

        // Test 8: packet_t valid
        test_count++;
        if (pkt.valid == 1) begin
            pass_count++;
            $display("Test 8 PASS: packet_t.valid = %b", pkt.valid);
        end else begin
            $display("Test 8 FAIL");
        end

        // Test 9: state_t IDLE
        test_count++;
        st = IDLE;
        if (st == IDLE) begin
            pass_count++;
            $display("Test 9 PASS: state_t = IDLE (%b)", st);
        end else begin
            $display("Test 9 FAIL");
        end

        // Test 10: state_t RUN
        test_count++;
        st = RUN;
        if (st == RUN) begin
            pass_count++;
            $display("Test 10 PASS: state_t = RUN (%b)", st);
        end else begin
            $display("Test 10 FAIL");
        end

        // Test 11: state_t DONE
        test_count++;
        st = DONE;
        if (st == DONE) begin
            pass_count++;
            $display("Test 11 PASS: state_t = DONE (%b)", st);
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: byte_t operations
        test_count++;
        b = 8'h0F;
        b = b + 1;
        if (b == 8'h10) begin
            pass_count++;
            $display("Test 12 PASS: byte_t + 1 = %h", b);
        end else begin
            $display("Test 12 FAIL");
        end

        // Test 13: word_t operations
        test_count++;
        w = 16'h1000;
        w = w << 4;
        if (w == 16'h0000) begin
            pass_count++;
            $display("Test 13 PASS: word_t << 4 = %h (overflow)", w);
        end else begin
            $display("Test 13 FAIL: word_t << 4 unexpected = %h", w);
        end

        // Test 14: Array sum
        test_count++;
        begin
            static int sum = 0;
            for (int i = 0; i < 4; i++) sum += ba[i];
            // 8'h11 + 8'h22 + 8'h33 + 8'h44 = 170
            if (sum == 170) begin
                pass_count++;
                $display("Test 14 PASS: Array sum = %0d", sum);
            end else begin
                $display("Test 14 FAIL: Array sum = %0d", sum);
            end
        end

        // Test 15: Packet update
        test_count++;
        pkt.data = 8'hFF;
        pkt.valid = 0;
        if (pkt.data == 8'hFF && pkt.valid == 0) begin
            pass_count++;
            $display("Test 15 PASS: Packet updated");
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: State transition
        test_count++;
        st = IDLE;
        st = RUN;
        st = DONE;
        if (st == DONE) begin
            pass_count++;
            $display("Test 16 PASS: State transitions complete");
        end else begin
            $display("Test 16 FAIL");
        end

        // Test 17: Negative short
        test_count++;
        sh = -500;
        if (sh == -500) begin
            pass_count++;
            $display("Test 17 PASS: short_t = %0d", sh);
        end else begin
            $display("Test 17 FAIL");
        end

        // Test 18: byte_t max
        test_count++;
        b = 8'hFF;
        if (b == 8'hFF) begin
            pass_count++;
            $display("Test 18 PASS: byte_t max = %h", b);
        end else begin
            $display("Test 18 FAIL");
        end

        // Test 19: dword_t zero
        test_count++;
        d = 0;
        if (d == 0) begin
            pass_count++;
            $display("Test 19 PASS: dword_t zero = %h", d);
        end else begin
            $display("Test 19 FAIL");
        end

        $display("=== Typedef Advanced ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
