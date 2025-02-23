export const RPNErrorMessages = {
  INVALID_FORMAT: "Invalid RPN format. Numbers must be followed by operators. Example: '3 4 +'",
  MISSING_OPERANDS: "Not enough operands for operation. RPN format: '2 3 +'='5', '5 2 -'='3'",
  TOO_MANY_OPERANDS: "Too many operands. In RPN, each operator consumes two numbers.",
  DIVISION_BY_ZERO: "Division by zero is not allowed.",
};