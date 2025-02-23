import axios from "axios";
import { ServerResponse } from "./utils/types";



const API_BASE_URL = "http://127.0.0.1:8000";

export const evaluateExpression = async (value: string): Promise<ServerResponse> => {
  const response = await axios.post<ServerResponse>(`${API_BASE_URL}/evaluate`, { value });
  return response.data as ServerResponse;
};


export const exportCalculationsCSV = async (): Promise<Blob> => {
  const response = await axios.get(`${API_BASE_URL}/fetchData`, {
    responseType: 'blob'
  });
  return response.data;
};