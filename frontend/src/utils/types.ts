export interface CalculatorState {
  previousNumber: string;
  currentNumber: string;
  previousResult: string;
}

export interface ServerResponse {
  code: number;
  value: string;
  data?: number;
}