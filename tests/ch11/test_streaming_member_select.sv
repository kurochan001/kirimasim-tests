/*
:name: test_streaming_member_select
:description: Streaming assignment to struct members and part-selects
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_member_select.expected
*/
// IEEE 1800-2023 §11.4.14: Streaming assignment to struct members and part-selects
// Tests {>> {obj.field}} = src and {>> {sig[7:4]}} = src patterns
module test_streaming_member_select;

    typedef struct packed {
        logic [7:0] high_byte;
        logic [7:0] low_byte;
    } pair_t;

    pair_t pkt;
    logic [15:0] data;
    logic [31:0] wide_sig;
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

    task check32(string test_name, logic [31:0] actual, logic [31:0] expected);
        test_count++;
        if (actual === expected) begin
            pass_count++;
        end else begin
            $display("FAIL: %s - expected %h, got %h", test_name, expected, actual);
        end
    endtask

    task check8(string test_name, logic [7:0] actual, logic [7:0] expected);
        test_count++;
        if (actual === expected) begin
            pass_count++;
        end else begin
            $display("FAIL: %s - expected %h, got %h", test_name, expected, actual);
        end
    endtask

    initial begin
        // Test 1: Streaming assignment to struct member
        pkt = '0;
        {>> {pkt.high_byte, pkt.low_byte}} = 16'hABCD;
        check8("member high_byte", pkt.high_byte, 8'hAB);

        // Test 2: Low byte from streaming
        check8("member low_byte", pkt.low_byte, 8'hCD);

        // Test 3: Streaming to part-select target
        data = 16'h0000;
        {>> {data[15:8], data[7:0]}} = 16'hEF12;
        check("part-select", data, 16'hEF12);

        // Test 4: Streaming with bit-select
        wide_sig = 32'h0000_0000;
        wide_sig[0] = 1'b1;  // Direct bit-set for verification baseline
        check32("Baseline bit-set", wide_sig, 32'h0000_0001);

        // Test 5: Mixed identifier + member access streaming
        pkt = '0;
        data = 16'h0000;
        {>> {data, pkt.high_byte, pkt.low_byte}} = 32'h1234_5678;
        check("Mixed: data", data, 16'h1234);
        check8("Mixed: pkt.high_byte", pkt.high_byte, 8'h56);
        check8("Mixed: pkt.low_byte", pkt.low_byte, 8'h78);

        // Print summary
        $display("\n=== test_streaming_member_select ===");
        if (pass_count == test_count) begin
            $display("PASS: All %0d tests passed", test_count);
        end else begin
            $display("FAIL: %0d/%0d tests passed", pass_count, test_count);
        end
        $finish;
    end
endmodule
