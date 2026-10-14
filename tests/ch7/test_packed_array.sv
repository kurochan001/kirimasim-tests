/*
:name: test_packed_array
:description: Packed Array Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_array.expected
*/
// IEEE 1800-2023 Section 7.4 - Packed Array Tests
// Tests: packed arrays, packed structs, bit slicing

module test_packed_array;
    int pass_count = 0;
    int fail_count = 0;

    // Packed array types
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
    logic [3:0][7:0] packed_array;

    // Packed struct
    typedef struct packed {
        logic [7:0] header;
        logic [15:0] data;
        logic [7:0] footer;
    } packet_t;

    packet_t pkt;

    initial begin
        $display("=== IEEE 1800-2023 Packed Array Test ===");

        // Test 1: Byte access
        $display("Test 1: Byte access");
        byte_val = 8'hAB;
        $display("  byte_val=%h", byte_val);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: Bit slice access
        $display("Test 2: Bit slice access");
        word_val = 16'hCAFE;
        $display("  word_val=%h", word_val);
        $display("  word_val[15:8]=%h", word_val[15:8]);
        $display("  word_val[7:0]=%h", word_val[7:0]);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: Single bit access
        $display("Test 3: Single bit access");
        byte_val = 8'b10101010;
        $display("  byte_val[7]=%b", byte_val[7]);
        $display("  byte_val[0]=%b", byte_val[0]);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: Packed array element access
        $display("Test 4: Packed array element access");
        packed_array = 32'hDEADBEEF;
        $display("  packed_array=%h", packed_array);
        $display("  packed_array[3]=%h", packed_array[3]);
        $display("  packed_array[2]=%h", packed_array[2]);
        $display("  packed_array[1]=%h", packed_array[1]);
        $display("  packed_array[0]=%h", packed_array[0]);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: Packed struct access
        $display("Test 5: Packed struct access");
        pkt.header = 8'h01;
        pkt.data = 16'h2345;
        pkt.footer = 8'h67;
        $display("  pkt.header=%h", pkt.header);
        $display("  pkt.data=%h", pkt.data);
        $display("  pkt.footer=%h", pkt.footer);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: Packed struct as vector
        $display("Test 6: Packed struct as vector");
        $display("  pkt as vector=%h", pkt);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: Bit modification
        $display("Test 7: Bit modification");
        byte_val = 8'h00;
        byte_val[7] = 1;
        byte_val[0] = 1;
        $display("  byte_val after bit set=%h", byte_val);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: Part select modification
        $display("Test 8: Part select modification");
        dword_val = 32'h00000000;
        dword_val[31:24] = 8'hAA;
        dword_val[7:0] = 8'hBB;
        $display("  dword_val=%h", dword_val);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: Packed array iteration
        $display("Test 9: Packed array iteration");
        packed_array = 32'h12345678;
        for (int i = 0; i < 4; i++) begin
            $display("  packed_array[%0d]=%h", i, packed_array[i]);
        end
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Complex slice
        $display("Test 10: Complex slice");
        dword_val = 32'hFEDCBA98;
        $display("  dword_val[23:16]=%h", dword_val[23:16]);
        $display("  dword_val[19:12]=%h", dword_val[19:12]);
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
