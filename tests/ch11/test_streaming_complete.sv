/*
:name: test_streaming_complete
:description: Streaming a word into bytes and back with {>>{}} and {<<8{}}
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.2 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_complete.expected
*/
module test_streaming_complete;
    logic [31:0] data_in = 32'hDEADBEEF;
    logic [7:0] bytes[4];
    logic [31:0] data_out;

    initial begin
        $display("=== Complete Streaming Test ===");
        $display("Input data: %h", data_in);

        // Test 1: Big-endian streaming (MSB first)
        {>>{bytes}} = data_in;
        $display("Bytes after {>>{bytes}} = %h: %h %h %h %h",
                 data_in, bytes[0], bytes[1], bytes[2], bytes[3]);

        // Reconstruct from bytes
        data_out = {>>{bytes}};
        $display("Reconstructed with {>>{bytes}}: %h", data_out);

        // Test 2: Little-endian streaming (byte order reversal)
        // IEEE 1800-2023 §11.4.14: {<<8{}} reverses byte order
        {<<8{bytes}} = data_in;
        $display("Bytes after {<<8{bytes}} = %h: %h %h %h %h",
                 data_in, bytes[0], bytes[1], bytes[2], bytes[3]);

        // Reconstruct from bytes
        data_out = {<<8{bytes}};
        $display("Reconstructed with {<<8{bytes}}: %h", data_out);

        // Test 3: Verify reconstruction
        if (data_out == data_in) begin
            $display("SUCCESS: Data correctly reconstructed!");
        end else begin
            $display("FAIL: Data mismatch - expected %h, got %h", data_in, data_out);
        end

        $finish;
    end
endmodule
