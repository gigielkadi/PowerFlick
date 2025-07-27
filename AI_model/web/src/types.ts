export interface PowerConsumptionData {
  timestamp: string;
  consumption: number;
  predictedConsumption?: number;
}

export interface PowerConsumptionAnomaly {
  timestamp: string;
  value: number;
  deviationPercentage: number;
  type: 'high_deviation' | 'low_deviation';
  severity: 'high' | 'medium' | 'low';
}

export interface ModelMetrics {
  mse: number;
  rmse: number;
  mae: number;
  accuracy: number;
}

export interface PredictionResponse {
  predictions: PowerConsumptionData[];
  anomalies: PowerConsumptionAnomaly[];
} 