import axios, { AxiosError } from "axios";
import { ServerResponse } from "./utils/types";



const API_BASE_URL = "http://127.0.0.1:8000";

export const evaluateExpression = async (expression: string): Promise<ServerResponse> => {
  try {
    const response = await axios.post<ServerResponse>(`${API_BASE_URL}/evaluate`, { expression });
    return response.data as ServerResponse;
  } catch (err) {
    const errors = err as Error | AxiosError;
    console.error(errors);
    if (axios.isAxiosError(errors)) {
      // Access to config, request, and response
    } else {
      // Just a stock error
    }
    throw err;
  }
};
