/*
:name: test_operator_index
:description: Index operators test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_index.expected
*/
// Index operators test
module test_operator_index;
    logic [31:0] word;
    logic [7:0] arr [0:3];
    logic [3:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Single bit select
        word = 32'hCAFEBABE;
        if (word[0] == 1'b0) begin
            $display("PASS: word[0] of 0xCAFEBABE = 0");
            pass_count++;
        end else begin
            $display("FAIL: word[0], expected 0, got %b", word[0]);
            fail_count++;
        end

        // Test 2: Part select (constant range)
        result = word[7:4];
        if (result == 4'hB) begin
            $display("PASS: word[7:4] of 0xCAFEBABE = 0xB");
            pass_count++;
        end else begin
            $display("FAIL: word[7:4], expected 0xB, got 0x%01X", result);
            fail_count++;
        end

        // Test 3: Indexed part select +: (ascending)
        result = word[8 +: 4];
        if (result == 4'hA) begin
            $display("PASS: word[8 +: 4] of 0xCAFEBABE = 0xA");
            pass_count++;
        end else begin
            $display("FAIL: word[8 +: 4], expected 0xA, got 0x%01X", result);
            fail_count++;
        end

        // Test 4: Indexed part select -: (descending)
        result = word[15 -: 4];
        if (result == 4'hB) begin
            $display("PASS: word[15 -: 4] of 0xCAFEBABE = 0xB");
            pass_count++;
        end else begin
            $display("FAIL: word[15 -: 4], expected 0xB, got 0x%01X", result);
            fail_count++;
        end

        // Test 5: Array index
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;
        if (arr[2] == 8'h30) begin
            $display("PASS: arr[2] = 0x30");
            pass_count++;
        end else begin
            $display("FAIL: arr[2], expected 0x30, got 0x%02X", arr[2]);
            fail_count++;
        end

        // Summary
        $display("Index operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All index operator tests passed");
        else $display("FAIL: Some index operator tests failed");
        $finish;
    end
endmodule
