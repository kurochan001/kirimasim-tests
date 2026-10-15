/*
:name: test_streaming_pack_unpack
:description: Streaming operators basic test (IEEE 1800-2023 11.4.14)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_pack_unpack.expected
*/
// Streaming operators basic test (IEEE 1800-2023 11.4.14)
module test_streaming_pack_unpack;
  initial begin
    static bit [31:0] word = 32'h12345678;
    bit [7:0] bytes[4];
    bit [31:0] reconstructed;

    // Pack: word -> byte array (little-endian, 8-bit slices)
    bytes = {<<8{word}};
    $display("Packed bytes: %h %h %h %h", bytes[0], bytes[1], bytes[2], bytes[3]);
    assert(bytes[0] == 8'h78) else $fatal(1, "bytes[0] == 8'h78 failed");
    assert(bytes[1] == 8'h56) else $fatal(1, "bytes[1] == 8'h56 failed");
    assert(bytes[2] == 8'h34) else $fatal(1, "bytes[2] == 8'h34 failed");
    assert(bytes[3] == 8'h12) else $fatal(1, "bytes[3] == 8'h12 failed");

    // Unpack: byte array -> word
    reconstructed = {<<8{bytes}};
    $display("Reconstructed word: %h", reconstructed);
    assert(reconstructed == word) else $fatal(1, "reconstructed == word failed");

    $display("Streaming operators pack/unpack test PASSED");
    $finish;
  end
endmodule
