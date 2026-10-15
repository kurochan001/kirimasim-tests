/*
:name: test_lexical_strings
:description: Chapter 5.9: String literals
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 5.9.1 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lexical_strings.expected
*/
// IEEE 1800-2023 Chapter 5.9: String literals
// Test various string literal formats and escape sequences

module test_lexical_strings;
    string str_simple;
    string str_escape_newline;
    string str_escape_tab;
    string str_escape_backslash;
    string str_escape_quote;
    string str_escape_hex;
    string str_escape_octal;
    string str_concat;
    string str_empty;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // §5.9 Simple string literal
        str_simple = "Hello, World!";
        test_count++;
        if (str_simple == "Hello, World!") pass_count++;
        else $display("FAIL: str_simple mismatch");

        // §5.9 Empty string
        str_empty = "";
        test_count++;
        if (str_empty.len() == 0) pass_count++;
        else $display("FAIL: str_empty should have length 0, got %0d", str_empty.len());

        // §5.9 Escape sequences - newline
        str_escape_newline = "line1\nline2";
        test_count++;
        if (str_escape_newline.len() == 11) pass_count++;  // "line1" + "\n" + "line2" = 11 chars
        else $display("FAIL: str_escape_newline length expected 11, got %0d", str_escape_newline.len());

        // §5.9 Escape sequences - tab
        str_escape_tab = "col1\tcol2";
        test_count++;
        if (str_escape_tab.len() == 9) pass_count++;  // "col1" + "\t" + "col2" = 9 chars
        else $display("FAIL: str_escape_tab length expected 9, got %0d", str_escape_tab.len());

        // §5.9 Escape sequences - backslash
        str_escape_backslash = "path\\file";
        test_count++;
        if (str_escape_backslash.len() == 9) pass_count++;
        else $display("FAIL: str_escape_backslash length expected 9, got %0d", str_escape_backslash.len());

        // §5.9 Escape sequences - double quote
        str_escape_quote = "He said \"Hello\"";
        test_count++;
        if (str_escape_quote.len() == 15) pass_count++;
        else $display("FAIL: str_escape_quote length expected 15, got %0d", str_escape_quote.len());

        // §5.9 String concatenation
        str_concat = {"Hello", ", ", "World!"};
        test_count++;
        if (str_concat == "Hello, World!") pass_count++;
        else $display("FAIL: str_concat expected 'Hello, World!', got '%s'", str_concat);

        // §5.9 String methods
        test_count++;
        if (str_simple.toupper() == "HELLO, WORLD!") pass_count++;
        else $display("FAIL: toupper expected 'HELLO, WORLD!'");

        test_count++;
        if (str_simple.tolower() == "hello, world!") pass_count++;
        else $display("FAIL: tolower expected 'hello, world!'");

        // §5.9 Substring
        test_count++;
        if (str_simple.substr(0, 4) == "Hello") pass_count++;
        else $display("FAIL: substr(0,4) expected 'Hello', got '%s'", str_simple.substr(0, 4));

        // §5.9 String comparison
        test_count++;
        if ("abc" < "abd") pass_count++;
        else $display("FAIL: 'abc' should be less than 'abd'");

        test_count++;
        if ("abc" == "abc") pass_count++;
        else $display("FAIL: 'abc' should equal 'abc'");

        // Summary
        $display("Chapter 5.9 String Literals: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
