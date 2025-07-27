import axios from 'axios';
import { PowerConsumptionData, PredictionResponse, ModelMetrics } from '../types';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8000/api',
});

export const getPowerConsumptionData = async (
  deviceId: string,
  startDate: Date,
  endDate: Date
): Promise<PowerConsumptionData[]> => {
  const response = await api.get(`/power-consumption/${deviceId}`, {
    params: {
      start_date: startDate.toISOString(),
      end_date: endDate.toISOString(),
    },
  });
  return response.data;
};

export const getPredictions = async (
  deviceId: string
): Promise<PredictionResponse> => {
  const response = await api.get(`/predictions/${deviceId}`);
  return response.data;
};

export const getModelMetrics = async (
  deviceId: string
): Promise<ModelMetrics> => {
  const response = await api.get(`/model-metrics/${deviceId}`);
  return response.data;
};

export const trainModel = async (deviceId: string): Promise<void> => {
  await api.post(`/train-model/${deviceId}`);
}; 