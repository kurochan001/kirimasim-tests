/*
:name: test_streaming_complex_array
:description: Streaming operators with complex array bases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_complex_array.expected
*/
// IEEE 1800-2023 §11.4.14 Streaming operators with complex array bases
// Tests streaming assignment with obj.arr[i] style operands

module test_streaming_complex_array;
    // Test structure with nested array
    typedef struct {
        logic [7:0] bytes[4];
        logic [31:0] id;
    } packet_t;

    // Class with array member for testing
    class DataContainer;
        logic [7:0] data[4];
        logic [15:0] header;

        function new();
            foreach (data[i]) data[i] = 8'h00;
            header = 16'h0000;
        endfunction
    endclass

    packet_t pkt;
    DataContainer obj;
    logic [31:0] source_data;
    logic [31:0] result;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Streaming Complex Array Base Test (IEEE 1800-2023 §11.4.14) ===");

        // Initialize
        pkt.id = 32'h12345678;
        foreach (pkt.bytes[i]) pkt.bytes[i] = 8'h00;
        obj = new();

        // Test 1: Streaming to struct member array element
        $display("\n--- Test 1: Streaming to struct.arr[i] ---");
        source_data = 32'hAABBCCDD;

        // This should work: streaming to individual elements via struct member
        {>>{ pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3] }} = source_data;

        if (pkt.bytes[0] == 8'hAA && pkt.bytes[1] == 8'hBB &&
            pkt.bytes[2] == 8'hCC && pkt.bytes[3] == 8'hDD) begin
            $display("PASS: pkt.bytes = {0x%h, 0x%h, 0x%h, 0x%h}",
                     pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3]);
            passed++;
        end else begin
            $display("FAIL: pkt.bytes = {0x%h, 0x%h, 0x%h, 0x%h}, expected {AA,BB,CC,DD}",
                     pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3]);
            failed++;
        end

        // Test 2: Verify struct.id not corrupted
        $display("\n--- Test 2: Verify struct.id preserved ---");
        if (pkt.id == 32'h12345678) begin
            $display("PASS: pkt.id = 0x%h (preserved)", pkt.id);
            passed++;
        end else begin
            $display("FAIL: pkt.id = 0x%h, expected 0x12345678", pkt.id);
            failed++;
        end

        // Test 3: Streaming to class member array element
        $display("\n--- Test 3: Streaming to obj.data[i] ---");
        obj.header = 16'hABCD;
        source_data = 32'h11223344;

        {>>{ obj.data[0], obj.data[1], obj.data[2], obj.data[3] }} = source_data;

        if (obj.data[0] == 8'h11 && obj.data[1] == 8'h22 &&
            obj.data[2] == 8'h33 && obj.data[3] == 8'h44) begin
            $display("PASS: obj.data = {0x%h, 0x%h, 0x%h, 0x%h}",
                     obj.data[0], obj.data[1], obj.data[2], obj.data[3]);
            passed++;
        end else begin
            $display("FAIL: obj.data = {0x%h, 0x%h, 0x%h, 0x%h}, expected {11,22,33,44}",
                     obj.data[0], obj.data[1], obj.data[2], obj.data[3]);
            failed++;
        end

        // Test 4: Verify class header not corrupted
        $display("\n--- Test 4: Verify obj.header preserved ---");
        if (obj.header == 16'hABCD) begin
            $display("PASS: obj.header = 0x%h (preserved)", obj.header);
            passed++;
        end else begin
            $display("FAIL: obj.header = 0x%h, expected 0xABCD", obj.header);
            failed++;
        end

        // Test 5: Left-to-right streaming with complex base
        $display("\n--- Test 5: Left-to-right streaming {<<} ---");
        source_data = 32'h55667788;

        {<<8{ pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3] }} = source_data;

        // {<<8{...}} reverses byte order
        if (pkt.bytes[0] == 8'h88 && pkt.bytes[1] == 8'h77 &&
            pkt.bytes[2] == 8'h66 && pkt.bytes[3] == 8'h55) begin
            $display("PASS: {<<8} pkt.bytes = {0x%h, 0x%h, 0x%h, 0x%h}",
                     pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3]);
            passed++;
        end else begin
            $display("FAIL: {<<8} pkt.bytes = {0x%h, 0x%h, 0x%h, 0x%h}, expected {88,77,66,55}",
                     pkt.bytes[0], pkt.bytes[1], pkt.bytes[2], pkt.bytes[3]);
            failed++;
        end

        $display("\n=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
