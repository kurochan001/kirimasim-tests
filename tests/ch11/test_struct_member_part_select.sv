/*
:name: test_struct_member_part_select
:description: Tests obj.signal[high:low] = value pattern in sequential blocks
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 7.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_member_part_select.expected
*/
// Tests obj.signal[high:low] = value pattern in sequential blocks
module test_struct_member_part_select;

    typedef struct packed {
        logic [15:0] upper;
        logic [15:0] lower;
    } pair_t;

    pair_t data;
    int test_count = 0;
    int pass_count = 0;

    task check(string test_name, logic [15:0] actual, logic [15:0] expected);
        test_count++;
        if (actual === expected) begin
            pass_count++;
        end else begin
            $display("FAIL: %s - expected %h, got %h", test_name, expected, actual);
        end
    endtask

    initial begin
        // Test 1: Basic member part-select assignment
        data = '0;
        data.upper[15:8] = 8'hAB;
        check("upper[15:8] = 0xAB", data.upper, 16'hAB00);

        // Test 2: Lower byte of upper member
        data.upper[7:0] = 8'hCD;
        check("upper[7:0] = 0xCD", data.upper, 16'hABCD);

        // Test 3: Lower member part-select
        data.lower[15:8] = 8'hEF;
        check("lower[15:8] = 0xEF", data.lower, 16'hEF00);

        // Test 4: Full lower byte
        data.lower[7:0] = 8'h12;
        check("lower[7:0] = 0x12", data.lower, 16'hEF12);

        // Test 5: Single bit via part-select
        data.upper = 16'h0000;
        data.upper[0:0] = 1'b1;
        check("upper[0:0] = 1", data.upper, 16'h0001);

        // Test 6: Mid-range select
        data.lower = 16'h0000;
        data.lower[11:4] = 8'hFF;
        check("lower[11:4] = 0xFF", data.lower, 16'h0FF0);

        // Print summary
        $display("\n=== test_struct_member_part_select ===");
        if (pass_count == test_count) begin
            $display("PASS: All %0d tests passed", test_count);
        end else begin
            $display("FAIL: %0d/%0d tests passed", pass_count, test_count);
        end
        $finish;
    end
endmodule
