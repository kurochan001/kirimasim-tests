/*
:name: test_multidim_packed_vector
:description: Two-dimensional packed vectors driven bit by bit from nested generate loops
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.5 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multidim_packed_vector.expected
*/
// test_multidim_packed_vector.sv
// in generate for loop continuous assignments
// IEEE 1800-2023 §7.4.5: Packed array linear bit indexing

module test_multidim_packed_vector;

    int pass_count = 0;
    int test_count = 0;

    // Test 1: Nested generate loops creating multi-dim LHS strings
    // logic [1:0][3:0] = 8 bits total
    // data[i][j] should set bit at i*4+j
    logic [1:0][3:0] data2x4;

    genvar gi, gj;
    generate
        for (gi = 0; gi < 2; gi++) begin : gen_outer
            for (gj = 0; gj < 4; gj++) begin : gen_inner
                // Creates LHS strings like data2x4[0][0], data2x4[0][1], etc.
                // Source pattern: bit (gi+gj) % 2
                assign data2x4[gi][gj] = (gi + gj) % 2;
            end
        end
    endgenerate

    // Test 2: 4x4 packed array with nested generates
    logic [3:0][3:0] data4x4;

    generate
        for (gi = 0; gi < 4; gi++) begin : gen_4x4_outer
            for (gj = 0; gj < 4; gj++) begin : gen_4x4_inner
                assign data4x4[gi][gj] = (gi == gj) ? 1'b1 : 1'b0;
            end
        end
    endgenerate

    // Test 3: Single-dim packed array with generate (1D reference)
    logic [7:0] data8;

    generate
        for (gi = 0; gi < 8; gi++) begin : gen_1d
            assign data8[gi] = (gi % 2 == 0) ? 1'b1 : 1'b0;
        end
    endgenerate

    // Test 4: 2x8 packed array
    logic [1:0][7:0] data2x8;

    generate
        for (gi = 0; gi < 2; gi++) begin : gen_2x8_outer
            for (gj = 0; gj < 8; gj++) begin : gen_2x8_inner
                assign data2x8[gi][gj] = gi[0] ^ gj[0];
            end
        end
    endgenerate

    initial begin
        #1;

        // Test 1: 2x4 packed array with nested generate
        // data2x4[0][0] = 0, [0][1] = 1, [0][2] = 0, [0][3] = 1 => 4'b1010 = 0xA
        // data2x4[1][0] = 1, [1][1] = 0, [1][2] = 1, [1][3] = 0 => 4'b0101 = 0x5
        // Total: 8'h5A
        test_count++;
        if (data2x4[0] === 4'hA) pass_count++;
        else $display("FAIL T1: data2x4[0] = %h, expected A", data2x4[0]);

        test_count++;
        if (data2x4[1] === 4'h5) pass_count++;
        else $display("FAIL T2: data2x4[1] = %h, expected 5", data2x4[1]);

        test_count++;
        if (data2x4 === 8'h5A) pass_count++;
        else $display("FAIL T3: data2x4 = %h, expected 5A", data2x4);

        // Test 2: 4x4 identity matrix pattern
        // data4x4[0] = 4'b0001, [1] = 4'b0010, [2] = 4'b0100, [3] = 4'b1000
        // = 16'h8421
        test_count++;
        if (data4x4[0] === 4'h1) pass_count++;
        else $display("FAIL T4: data4x4[0] = %h, expected 1", data4x4[0]);

        test_count++;
        if (data4x4[1] === 4'h2) pass_count++;
        else $display("FAIL T5: data4x4[1] = %h, expected 2", data4x4[1]);

        test_count++;
        if (data4x4[2] === 4'h4) pass_count++;
        else $display("FAIL T6: data4x4[2] = %h, expected 4", data4x4[2]);

        test_count++;
        if (data4x4[3] === 4'h8) pass_count++;
        else $display("FAIL T7: data4x4[3] = %h, expected 8", data4x4[3]);

        test_count++;
        if (data4x4 === 16'h8421) pass_count++;
        else $display("FAIL T8: data4x4 = %h, expected 8421", data4x4);

        // Test 3: 1D packed array reference
        // Even bits = 1, odd bits = 0 => 8'b01010101 = 8'h55
        test_count++;
        if (data8 === 8'h55) pass_count++;
        else $display("FAIL T9: data8 = %h, expected 55", data8);

        // Test 4: 2x8 packed array
        // data2x8[0][j] = 0 ^ j[0] = j[0], so data2x8[0] = 8'b10101010 = 8'hAA
        // data2x8[1][j] = 1 ^ j[0] = ~j[0], so data2x8[1] = 8'b01010101 = 8'h55
        // Total: 16'h55AA
        test_count++;
        if (data2x8[0] === 8'hAA) pass_count++;
        else $display("FAIL T10: data2x8[0] = %h, expected AA", data2x8[0]);

        test_count++;
        if (data2x8[1] === 8'h55) pass_count++;
        else $display("FAIL T11: data2x8[1] = %h, expected 55", data2x8[1]);

        test_count++;
        if (data2x8 === 16'h55AA) pass_count++;
        else $display("FAIL T12: data2x8 = %h, expected 55AA", data2x8);

        $display("%0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count)
            $display("PASS");
        else
            $display("FAIL");
    end

endmodule
