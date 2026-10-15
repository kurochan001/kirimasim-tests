/*
:name: test_ieee1800_2023_streaming_complex
:description: Streaming Operator Complex Edge Cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_streaming_complex.expected
*/
// IEEE 1800-2023 Streaming Operator Complex Edge Cases
// Sections: §11.4.14 (Streaming operators)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_streaming_complex;

    initial begin
        static int pass_count = 0;
        static int total_tests = 20;

        // Test 1: Basic streaming left-to-right
        begin
            logic [31:0] packed_val;
            logic [7:0] bytes[4];

            packed_val = 32'hDEADBEEF;
            {>>{bytes}} = packed_val;

            if (bytes[0] == 8'hDE && bytes[1] == 8'hAD &&
                bytes[2] == 8'hBE && bytes[3] == 8'hEF) begin
                $display("PASS: Test 1 - Basic streaming left-to-right");
                pass_count++;
            end else $display("FAIL: Test 1 - Got bytes[0]=%h", bytes[0]);
        end

        // Test 2: Basic streaming right-to-left
        begin
            logic [31:0] packed_val;
            logic [7:0] bytes[4];

            packed_val = 32'hCAFEBABE;
            {<<{bytes}} = packed_val;

            // IEEE 1800-2023 §11.4.14: with no slice_size the slice is 1 bit, so
            // {<<{...}} reverses the BIT order of the whole stream and bytes[0]
            // takes the first 8 reversed bits: 32'hCAFEBABE -> 32'h7D5D7F53.
            // (Byte-wise reversal is {<<8{...}}.)
            if (bytes[0] == 8'h7D && bytes[1] == 8'h5D &&
                bytes[2] == 8'h7F && bytes[3] == 8'h53) begin
                $display("PASS: Test 2 - Basic streaming right-to-left");
                pass_count++;
            end else $display("FAIL: Test 2 - Got bytes[0]=%h", bytes[0]);
        end

        // Test 3: Streaming with slice size
        begin
            logic [31:0] val;
            logic [15:0] words[2];

            val = 32'h12345678;
            {>>{words}} = val;

            if (words[0] == 16'h1234 && words[1] == 16'h5678) begin
                $display("PASS: Test 3 - Streaming with implicit slice");
                pass_count++;
            end else $display("FAIL: Test 3 - Got words[0]=%h", words[0]);
        end

        // Test 4: Streaming with explicit slice size
        begin
            logic [31:0] val;
            logic [7:0] result[4];

            val = 32'hAABBCCDD;
            {<<8{result}} = val;

            if (result[0] == 8'hDD && result[1] == 8'hCC &&
                result[2] == 8'hBB && result[3] == 8'hAA) begin
                $display("PASS: Test 4 - Streaming with explicit slice size");
                pass_count++;
            end else $display("FAIL: Test 4 - Got result[0]=%h", result[0]);
        end

        // Test 5: Streaming concatenation source
        begin
            logic [7:0] a, b, c, d;
            logic [31:0] result;

            a = 8'h11;
            b = 8'h22;
            c = 8'h33;
            d = 8'h44;

            result = {>>{a, b, c, d}};

            if (result == 32'h11223344) begin
                $display("PASS: Test 5 - Streaming concatenation source");
                pass_count++;
            end else $display("FAIL: Test 5 - Got %h", result);
        end

        // Test 6: Streaming to dynamic array
        begin
            logic [63:0] val;
            logic [7:0] dyn_arr[];

            val = 64'h0102030405060708;
            dyn_arr = new[8];
            {>>{dyn_arr}} = val;

            if (dyn_arr[0] == 8'h01 && dyn_arr[7] == 8'h08) begin
                $display("PASS: Test 6 - Streaming to dynamic array");
                pass_count++;
            end else $display("FAIL: Test 6 - Got dyn_arr[0]=%h", dyn_arr[0]);
        end

        // Test 7: Nested streaming
        begin
            logic [15:0] val;
            logic [3:0] nibbles[4];

            val = 16'hABCD;
            {>>{nibbles}} = val;

            if (nibbles[0] == 4'hA && nibbles[1] == 4'hB &&
                nibbles[2] == 4'hC && nibbles[3] == 4'hD) begin
                $display("PASS: Test 7 - Nested streaming nibbles");
                pass_count++;
            end else $display("FAIL: Test 7 - Got nibbles[0]=%h", nibbles[0]);
        end

        // Test 8: Streaming with struct
        begin
            typedef struct packed {
                logic [7:0] a;
                logic [7:0] b;
                logic [7:0] c;
                logic [7:0] d;
            } quad_t;

            quad_t q;
            logic [7:0] arr[4];

            q.a = 8'h10;
            q.b = 8'h20;
            q.c = 8'h30;
            q.d = 8'h40;

            {>>{arr}} = q;

            if (arr[0] == 8'h10 && arr[1] == 8'h20 &&
                arr[2] == 8'h30 && arr[3] == 8'h40) begin
                $display("PASS: Test 8 - Streaming with packed struct");
                pass_count++;
            end else $display("FAIL: Test 8 - Got arr[0]=%h", arr[0]);
        end

        // Test 9: Streaming reverse direction with struct
        begin
            typedef struct packed {
                logic [7:0] a;
                logic [7:0] b;
            } pair_t;

            pair_t p;
            logic [7:0] arr[2];

            p.a = 8'hAA;
            p.b = 8'hBB;

            {<<{arr}} = p;

            // IEEE 1800-2023 §11.4.14: default slice is 1 bit, so the 16-bit
            // stream 16'hAABB is bit-reversed to 16'hDD55 before unpacking
            // left to right: arr[0] = 8'hDD, arr[1] = 8'h55.
            if (arr[0] == 8'hDD && arr[1] == 8'h55) begin
                $display("PASS: Test 9 - Streaming reverse with struct");
                pass_count++;
            end else $display("FAIL: Test 9 - Got arr[0]=%h, arr[1]=%h", arr[0], arr[1]);
        end

        // Test 10: Streaming array to packed
        begin
            logic [7:0] bytes[4];
            logic [31:0] result;

            bytes[0] = 8'hAA;
            bytes[1] = 8'hBB;
            bytes[2] = 8'hCC;
            bytes[3] = 8'hDD;

            result = {>>{bytes}};

            if (result == 32'hAABBCCDD) begin
                $display("PASS: Test 10 - Streaming array to packed");
                pass_count++;
            end else $display("FAIL: Test 10 - Got %h", result);
        end

        // Test 11: Streaming with bit reversal
        begin
            logic [7:0] val;
            logic [7:0] result;

            val = 8'b10110001;
            result = {<<1{val}};  // Bit-by-bit reversal

            if (result == 8'b10001101) begin
                $display("PASS: Test 11 - Streaming bit reversal");
                pass_count++;
            end else $display("FAIL: Test 11 - Got %b", result);
        end

        // Test 12: Streaming with 2-bit slice reversal
        begin
            logic [7:0] val;
            logic [7:0] result;

            val = 8'b11_10_01_00;
            result = {<<2{val}};  // 2-bit slice reversal

            if (result == 8'b00_01_10_11) begin
                $display("PASS: Test 12 - Streaming 2-bit slice reversal");
                pass_count++;
            end else $display("FAIL: Test 12 - Got %b", result);
        end

        // Test 13: Streaming mixed sizes
        begin
            logic [23:0] val;
            logic [7:0] a;
            logic [15:0] b;

            val = 24'hABCDEF;
            {>>{a, b}} = val;

            if (a == 8'hAB && b == 16'hCDEF) begin
                $display("PASS: Test 13 - Streaming mixed sizes");
                pass_count++;
            end else $display("FAIL: Test 13 - Got a=%h, b=%h", a, b);
        end

        // Test 14: Streaming queue target
        begin
            logic [31:0] val;
            logic [7:0] queue[$];

            val = 32'h01020304;
            queue = '{8'h00, 8'h00, 8'h00, 8'h00};
            {>>{queue}} = val;

            if (queue[0] == 8'h01 && queue[3] == 8'h04) begin
                $display("PASS: Test 14 - Streaming queue target");
                pass_count++;
            end else $display("FAIL: Test 14 - Got queue[0]=%h", queue[0]);
        end

        // Test 15: Streaming with enum
        begin
            typedef enum logic [1:0] {A=0, B=1, C=2, D=3} state_t;
            state_t states[4];
            logic [7:0] val;

            val = 8'b11_10_01_00;
            {>>{states}} = val;

            if (states[0] == D && states[1] == C &&
                states[2] == B && states[3] == A) begin
                $display("PASS: Test 15 - Streaming with enum");
                pass_count++;
            end else $display("FAIL: Test 15 - Got states[0]=%0d", states[0]);
        end

        // Test 16: Empty streaming (edge case)
        begin
            static logic [7:0] val = 8'hFF;
            logic [7:0] result;

            result = {>>{val}};  // Identity operation

            if (result == 8'hFF) begin
                $display("PASS: Test 16 - Identity streaming");
                pass_count++;
            end else $display("FAIL: Test 16 - Got %h", result);
        end

        // Test 17: Streaming with signed values
        begin
            logic signed [15:0] sval;
            logic [7:0] bytes[2];

            sval = -1;  // 16'hFFFF
            {>>{bytes}} = sval;

            if (bytes[0] == 8'hFF && bytes[1] == 8'hFF) begin
                $display("PASS: Test 17 - Streaming signed value");
                pass_count++;
            end else $display("FAIL: Test 17 - Got bytes[0]=%h", bytes[0]);
        end

        // Test 18: Large streaming operation
        begin
            logic [127:0] big_val;
            logic [7:0] big_arr[16];

            big_val = 128'h0102030405060708090A0B0C0D0E0F10;
            {>>{big_arr}} = big_val;

            if (big_arr[0] == 8'h01 && big_arr[15] == 8'h10) begin
                $display("PASS: Test 18 - Large streaming operation");
                pass_count++;
            end else $display("FAIL: Test 18 - Got big_arr[0]=%h", big_arr[0]);
        end

        // Test 19: Streaming to multidimensional array element
        begin
            logic [15:0] val;
            logic [7:0] matrix[2][2];

            val = 16'hABCD;
            {>>{matrix[0][0], matrix[0][1]}} = val;

            if (matrix[0][0] == 8'hAB && matrix[0][1] == 8'hCD) begin
                $display("PASS: Test 19 - Streaming to 2D array elements");
                pass_count++;
            end else $display("FAIL: Test 19 - Got matrix[0][0]=%h", matrix[0][0]);
        end

        // Test 20: Bidirectional streaming combination
        begin
            logic [15:0] val;
            logic [15:0] result;

            val = 16'hABCD;
            result = {<<8{{>>{val}}}};  // First stream left, then reverse by bytes

            if (result == 16'hCDAB) begin
                $display("PASS: Test 20 - Bidirectional streaming combination");
                pass_count++;
            end else $display("FAIL: Test 20 - Got %h", result);
        end

        $display("\n=== Streaming Operator Complex Summary ===");
        $display("Tests passed: %0d/%0d", pass_count, total_tests);
        if (pass_count == total_tests) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
        $finish;
    end

endmodule
