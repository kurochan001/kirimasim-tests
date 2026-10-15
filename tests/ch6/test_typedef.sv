/*
:name: test_typedef
:description: typedef of vectors, an enum and a packed struct
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef.expected
*/
// IEEE 1800-2023 Typedef (§6.18)
// Tests type definition

module test_typedef;
    // Basic typedef
    typedef logic [7:0] byte_t;
    typedef logic [15:0] word_t;
    typedef logic [31:0] dword_t;

    // Enum typedef
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        READ = 2'b01,
        WRITE = 2'b10,
        ERROR = 2'b11
    } state_t;

    // Struct typedef
    typedef struct packed {
        logic [7:0] header;
        logic [15:0] payload;
        logic [7:0] checksum;
    } packet_t;

    initial begin
        byte_t b;
        word_t w;
        dword_t d;
        state_t state;
        packet_t pkt;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Basic typedef
        b = 8'hAB;
        w = 16'hCDEF;
        d = 32'h12345678;

        if (b == 8'hAB && w == 16'hCDEF && d == 32'h12345678) begin
            $display("PASS: Basic typedef values correct");
            pass_count++;
        end else begin
            $display("FAIL: Basic typedef values incorrect");
            fail_count++;
        end

        // Test 2: Enum typedef
        state = IDLE;
        if (state == 2'b00) begin
            $display("PASS: Enum IDLE = %0d", state);
            pass_count++;
        end else begin
            $display("FAIL: Enum IDLE wrong value");
            fail_count++;
        end

        state = WRITE;
        if (state == 2'b10) begin
            $display("PASS: Enum WRITE = %0d", state);
            pass_count++;
        end else begin
            $display("FAIL: Enum WRITE wrong value");
            fail_count++;
        end

        // Test 3: Struct typedef
        pkt.header = 8'hFF;
        pkt.payload = 16'h1234;
        pkt.checksum = 8'hAA;

        if (pkt.header == 8'hFF && pkt.payload == 16'h1234 && pkt.checksum == 8'hAA) begin
            $display("PASS: Struct typedef values correct");
            pass_count++;
        end else begin
            $display("FAIL: Struct typedef values incorrect");
            fail_count++;
        end

        // Test 4: Struct packed size
        if ($bits(pkt) == 32) begin
            $display("PASS: Packed struct is 32 bits");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct size wrong: %0d", $bits(pkt));
            fail_count++;
        end

        $display("");
        $display("=== Typedef Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
