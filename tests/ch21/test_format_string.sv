/*
:name: test_format_string
:description: %s with string, packed vector and integral arguments
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.7 21.3.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_string.expected
*/
// %s with string, packed vector and integral arguments

module test_format_string;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    string str1, str2, result;
    logic [8*10-1:0] packed_str;
    logic [31:0] lv;
    byte ascii_chars [4];

    initial begin
        // Test 1: basic %s with string
        total_tests++;
        str1 = "Hello";
        $sformat(result, "%s", str1);
        if (result == "Hello") begin
            pass_count++;
            $display("PASS: basic %%s");
        end else $display("FAIL: basic %%s, got '%s'", result);

        // Test 2: empty string
        total_tests++;
        str1 = "";
        $sformat(result, "%s", str1);
        if (result == "") begin
            pass_count++;
            $display("PASS: empty string");
        end else $display("FAIL: empty string, got '%s'", result);

        // Test 3: string with spaces
        total_tests++;
        str1 = "Hello World";
        $sformat(result, "%s", str1);
        if (result == "Hello World") begin
            pass_count++;
            $display("PASS: string with spaces");
        end else $display("FAIL: with spaces, got '%s'", result);

        // Test 4: concatenated strings
        total_tests++;
        str1 = "Foo";
        str2 = "Bar";
        $sformat(result, "%s%s", str1, str2);
        if (result == "FooBar") begin
            pass_count++;
            $display("PASS: concatenated strings");
        end else $display("FAIL: concatenated, got '%s'", result);

        // Test 5: string with format text
        total_tests++;
        str1 = "Value";
        $sformat(result, "The %s is here", str1);
        if (result == "The Value is here") begin
            pass_count++;
            $display("PASS: string in sentence");
        end else $display("FAIL: in sentence, got '%s'", result);

        // Test 6: special characters
        total_tests++;
        str1 = "Tab\tNewline";
        $sformat(result, "%s", str1);
        if (result == "Tab\tNewline") begin
            pass_count++;
            $display("PASS: special characters");
        end else $display("FAIL: special chars");

        // Test 7: numeric characters
        total_tests++;
        str1 = "12345";
        $sformat(result, "%s", str1);
        if (result == "12345") begin
            pass_count++;
            $display("PASS: numeric string");
        end else $display("FAIL: numeric, got '%s'", result);

        // Test 8: mixed content
        total_tests++;
        str1 = "abc123XYZ";
        $sformat(result, "%s", str1);
        if (result == "abc123XYZ") begin
            pass_count++;
            $display("PASS: mixed content");
        end else $display("FAIL: mixed, got '%s'", result);

        // Test 9: packed array as string
        total_tests++;
        packed_str = "TestPacked";
        $sformat(result, "%s", packed_str);
        if (result == "TestPacked") begin
            pass_count++;
            $display("PASS: packed array as string");
        end else $display("FAIL: packed, got '%s'", result);

        // Test 10: logic vector as string (ASCII)
        total_tests++;
        lv = 32'h41424344;  // "ABCD"
        $sformat(result, "%s", lv);
        if (result == "ABCD") begin
            pass_count++;
            $display("PASS: logic as ASCII string");
        end else $display("FAIL: logic ASCII, got '%s'", result);

        // Test 11: multiple strings in format
        total_tests++;
        str1 = "First";
        str2 = "Second";
        $sformat(result, "[%s] and [%s]", str1, str2);
        if (result == "[First] and [Second]") begin
            pass_count++;
            $display("PASS: multiple strings");
        end else $display("FAIL: multiple, got '%s'", result);

        // Test 12: long string
        total_tests++;
        str1 = "This is a somewhat longer string for testing purposes";
        $sformat(result, "%s", str1);
        if (result == "This is a somewhat longer string for testing purposes") begin
            pass_count++;
            $display("PASS: long string");
        end else $display("FAIL: long string");

        // Test 13: string with punctuation
        total_tests++;
        str1 = "Hello, World! How are you?";
        $sformat(result, "%s", str1);
        if (result == "Hello, World! How are you?") begin
            pass_count++;
            $display("PASS: punctuation");
        end else $display("FAIL: punctuation, got '%s'", result);

        // Test 14: string assignment and format
        total_tests++;
        str1 = "Original";
        str2 = str1;
        $sformat(result, "%s", str2);
        if (result == "Original") begin
            pass_count++;
            $display("PASS: assigned string");
        end else $display("FAIL: assigned, got '%s'", result);

        $display("PASS: format_string (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
