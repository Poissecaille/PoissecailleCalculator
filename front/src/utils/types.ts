export interface CalculatorState {
  display: string;
  currentNumber: string;
}

export interface ServerResponse {
  code: number;
  value: string;
  data?: number;
}