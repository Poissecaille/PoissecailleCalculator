export const isValidRPNExpression = (expression: string): boolean => {
  const chars = expression.trim().split(/\s+/);
  const stack: number[] = [];

  for (const char of chars) {
    if (isOperator(char)) {
      if (stack.length < 2) {
        return false;
      }
      stack.pop();
      stack.pop();
      stack.push(1);
    } else {
      const num = parseFloat(char);
      if (typeof num !== 'number') {
        return false;
      }
      stack.push(num);
    }
  }

  return stack.length === 1;
}

export const isOperator = (value: string) => ['+', '-', '×', '÷'].includes(value);
