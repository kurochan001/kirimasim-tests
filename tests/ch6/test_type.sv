/*
:name: test_type
:description: Assignments between integral types, real conversion and string conversion methods
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.16.9 20.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type.expected
*/
module test_type;
    int pass_count = 0;
    int test_count = 0;
    
    // Various types
    logic [7:0] byte_val;
    logic [15:0] short_val;
    logic [31:0] word_val;
    logic [63:0] long_val;
    int signed_int;
    shortint short_int;
    longint long_int;
    real real_val;
    string str_val;
    
    initial begin
        // Test 1: Byte to word
        test_count++;
        byte_val = 8'hAB;
        word_val = byte_val;
        if (word_val == 32'h000000AB) pass_count++;
        
        // Test 2: Word to byte (truncation)
        test_count++;
        word_val = 32'h12345678;
        byte_val = word_val;
        if (byte_val == 8'h78) pass_count++;
        
        // Test 3: Signed extension
        test_count++;
        short_int = -1;
        signed_int = short_int;
        if (signed_int == -1) pass_count++;
        
        // Test 4: Unsigned extension
        test_count++;
        byte_val = 8'hFF;
        word_val = byte_val;
        if (word_val == 32'h000000FF) pass_count++;
        
        // Test 5: Real to int
        test_count++;
        real_val = 42.7;
        signed_int = $rtoi(real_val);
        if (signed_int == 42) pass_count++;
        
        // Test 6: Int to real
        test_count++;
        signed_int = 100;
        real_val = $itor(signed_int);
        if (real_val == 100.0) pass_count++;
        
        // Test 7: String to int
        test_count++;
        str_val = "12345";
        signed_int = str_val.atoi();
        if (signed_int == 12345) pass_count++;
        
        // Test 8: Int to string
        test_count++;
        signed_int = 67890;
        str_val.itoa(signed_int);
        if (str_val == "67890") pass_count++;
        
        // Test 9: Cast between sizes
        test_count++;
        long_val = 64'hFFFFFFFF_12345678;
        word_val = long_val[31:0];
        if (word_val == 32'h12345678) pass_count++;
        
        // Test 10: Mixed operations
        test_count++;
        byte_val = 8'd10;
        short_val = 16'd20;
        word_val = byte_val + short_val;
        if (word_val == 30) pass_count++;
        
        if (pass_count == test_count)
            $display("TEST PASSED: %0d/%0d", pass_count, test_count);
        else
            $display("TEST FAILED: %0d/%0d", pass_count, test_count);
        $finish;
    end
endmodule
