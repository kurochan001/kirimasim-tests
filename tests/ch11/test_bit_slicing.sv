/*
:name: test_bit_slicing
:description: Bit- and part-selects of a 32-bit vector, read directly and through assignments
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 21.2.1.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_slicing.expected
*/
// ビット範囲選択のテスト
module test_bit_slicing;

    logic [31:0] data;
    logic [6:0]  bits_6_0;
    logic [7:0]  bits_7_0;
    logic [4:0]  bits_11_7;
    logic [2:0]  bits_14_12;

    initial begin
        $display("=== Bit Slicing Test ===");

        // Test 1: 直接的なビット抽出
        data = 32'hDEADBEEF;
        $display("\nTest 1: Direct bit extraction");
        $display("data = 0x%08x", data);
        $display("data[6:0] = 0x%02x (expected: 0x6F)", data[6:0]);
        $display("data[7:0] = 0x%02x (expected: 0xEF)", data[7:0]);
        $display("data[15:8] = 0x%02x (expected: 0xBE)", data[15:8]);
        $display("data[31:24] = 0x%02x (expected: 0xDE)", data[31:24]);

        // Test 2: 変数への代入
        bits_6_0 = data[6:0];
        bits_7_0 = data[7:0];
        $display("\nTest 2: Assignment to variables");
        $display("bits_6_0 = 0x%02x (expected: 0x6F)", bits_6_0);
        $display("bits_7_0 = 0x%02x (expected: 0xEF)", bits_7_0);

        // Test 3: RISC-V命令デコード
        data = 32'h06400093;  // ADDI x1, x0, 100
        $display("\nTest 3: RISC-V instruction decode");
        $display("instruction = 0x%08x", data);
        $display("opcode (data[6:0]) = 0x%02x (expected: 0x13)", data[6:0]);
        $display("rd (data[11:7]) = %0d (expected: 1)", data[11:7]);
        $display("funct3 (data[14:12]) = 0x%01x (expected: 0x0)", data[14:12]);
        $display("rs1 (data[19:15]) = %0d (expected: 0)", data[19:15]);

        bits_6_0 = data[6:0];
        bits_11_7 = data[11:7];
        bits_14_12 = data[14:12];

        $display("\nVia assignment:");
        $display("opcode = 0x%02x", bits_6_0);
        $display("rd = %0d", bits_11_7);
        $display("funct3 = 0x%01x", bits_14_12);

        // Test 4: ビット選択の正確性
        if (data[6:0] == 7'h13) begin
            $display("\nPASS: bit slicing works correctly");
        end else begin
            $display("\n❌ Bit slicing failed: got 0x%02x, expected 0x13", data[6:0]);
        end

        $finish;
    end

endmodule
