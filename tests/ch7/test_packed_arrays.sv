/*
:name: test_packed_arrays
:description: Chapter 7: Aggregate data types
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_arrays.expected
*/
// IEEE 1800-2023 Chapter 7: Aggregate data types
// §7.4 Packed and unpacked arrays

module test_packed_arrays;
    // §7.4.1 Packed arrays
    logic [31:0] packed32;
    logic [7:0][3:0] packed_2d;  // 8 nibbles

    // §7.4.2 Unpacked arrays
    logic [7:0] unpacked[4];
    int arr[3];

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Packed array assignment
        packed32 = 32'hDEADBEEF;
        test_count++;
        if (packed32 == 32'hDEADBEEF) pass_count++;
        else $display("FAIL: packed32 - value=0x%0h", packed32);

        // Test 2: Packed array bit select
        test_count++;
        if (packed32[0] == 1'b1) pass_count++;
        else $display("FAIL: bit select - bit[0]=%0b", packed32[0]);

        // Test 3: Packed array part select
        test_count++;
        if (packed32[7:0] == 8'hEF) pass_count++;
        else $display("FAIL: part select - [7:0]=0x%0h", packed32[7:0]);

        // Test 4: 2D packed array
        packed_2d = 32'h12345678;
        test_count++;
        if (packed_2d[0] == 4'h8) pass_count++;
        else $display("FAIL: 2D packed - [0]=0x%0h", packed_2d[0]);

        // Test 5: Unpacked array element access
        unpacked[0] = 8'hAA;
        unpacked[1] = 8'hBB;
        unpacked[2] = 8'hCC;
        unpacked[3] = 8'hDD;
        test_count++;
        if (unpacked[2] == 8'hCC) pass_count++;
        else $display("FAIL: unpacked[2] - value=0x%0h", unpacked[2]);

        // Test 6: Int array
        arr[0] = 100;
        arr[1] = 200;
        arr[2] = 300;
        test_count++;
        if (arr[0] + arr[1] + arr[2] == 600) pass_count++;
        else $display("FAIL: int array sum - sum=%0d", arr[0]+arr[1]+arr[2]);

        $display("Chapter 7.4 Packed Arrays: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
