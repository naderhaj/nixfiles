# Exercise 01: Values and Types
# Run: nix eval -f training/01-language/exercises/e01-types.nix
#
# Each exercise is a key in the attrset below. Replace `null` with the correct value.
# When all answers are correct, the expression evaluates to an attrset of `true` values.

let
  # ── Exercise 1: What type is each value? ──────────────────────────────
  # Use builtins.typeOf to check. Replace null with the type string.

  # TODO: What does `builtins.typeOf 42` return?
  type_of_42 = "int";
  # EXPECTED: "int"

  # TODO: What does `builtins.typeOf 3.14` return?
  type_of_float = "float";
  # EXPECTED: "float"

  # TODO: What does `builtins.typeOf [ 1 2 ]` return?
  type_of_list = "list";
  # EXPECTED: "list"

  # TODO: What does `builtins.typeOf { a = 1; }` return?
  type_of_set = "set";
  # EXPECTED: "set"

  # TODO: What does `builtins.typeOf (x: x)` return?
  type_of_func = "lambda";
  # EXPECTED: "lambda"

  # ── Exercise 2: String interpolation ──────────────────────────────────

  greeting = "hello";

  # TODO: Use string interpolation to produce "hello world"
  hello_world = "${greeting} world";
  # EXPECTED: "hello world"
  # HINT: "${...} world"

  # TODO: Convert the integer 42 to the string "The answer is 42"
  answer_string = "The answer is ${toString 42}";
  # EXPECTED: "The answer is 42"
  # HINT: You need toString

  # ── Exercise 3: Integer vs float ──────────────────────────────────────

  # TODO: What is 7 / 2? (integer division)
  int_div = 7 / 2;
  # EXPECTED: 3

  # TODO: What is 7.0 / 2? (float division)
  float_div = 7.0 / 2;
  # EXPECTED: 3.5

  # ── Exercise 4: List operations ───────────────────────────────────────

  # TODO: Concatenate [ 1 2 ] and [ 3 4 ]
  concat = [
    1
    2
  ]
  ++ [
    3
    4
  ];
  # EXPECTED: [ 1 2 3 4 ]

  # TODO: Get the length of [ "a" "b" "c" "d" "e" ]
  len = builtins.length [
    "a"
    "b"
    "c"
    "d"
    "e"
  ];
  # EXPECTED: 5

  # ── Exercise 5: Multi-line strings ────────────────────────────────────

  # TODO: Write a multi-line string that evaluates to "line1\nline2\n"
  # HINT: Use '' ... '' syntax
  multiline = ''
    line1
    line2
  '';
  # EXPECTED: "line1\nline2\n"

in
{
  ex1_types =
    type_of_42 == "int"
    && type_of_float == "float"
    && type_of_list == "list"
    && type_of_set == "set"
    && type_of_func == "lambda";

  ex2_interpolation = hello_world == "hello world" && answer_string == "The answer is 42";

  ex3_division = int_div == 3 && float_div == 3.5;

  ex4_lists =
    concat == [
      1
      2
      3
      4
    ]
    && len == 5;

  ex5_multiline = multiline == "line1\nline2\n";

  what_is_this = "This is a test of your understanding of Nix types and values. If you see this, something went wrong.";
}
