import { useQuery, useQueryClient } from '@tanstack/react-query';
import { subHours } from 'date-fns';
import {
  getPowerConsumptionData,
  getPredictions,
  getModelMetrics,
} from '../services/api';
import { PowerConsumptionData, PowerConsumptionAnomaly, ModelMetrics } from '../types';

export const usePowerData = (deviceId: string) => {
  const queryClient = useQueryClient();
  const now = new Date();
  const twentyFourHoursAgo = subHours(now, 24);

  const {
    data: consumptionData = [],
    isLoading: isLoadingConsumption,
    error: consumptionError,
  } = useQuery<PowerConsumptionData[]>(
    ['powerConsumption', deviceId],
    () => getPowerConsumptionData(deviceId, twentyFourHoursAgo, now),
    {
      refetchInterval: 5 * 60 * 1000, // Refetch every 5 minutes
    }
  );

  const {
    data: predictions,
    isLoading: isLoadingPredictions,
    error: predictionsError,
  } = useQuery(
    ['predictions', deviceId],
    () => getPredictions(deviceId),
    {
      refetchInterval: 5 * 60 * 1000,
    }
  );

  const {
    data: metrics,
    isLoading: isLoadingMetrics,
    error: metricsError,
  } = useQuery<ModelMetrics>(
    ['modelMetrics', deviceId],
    () => getModelMetrics(deviceId),
    {
      refetchInterval: 15 * 60 * 1000, // Refetch every 15 minutes
    }
  );

  const refreshData = () => {
    queryClient.invalidateQueries(['powerConsumption', deviceId]);
    queryClient.invalidateQueries(['predictions', deviceId]);
    queryClient.invalidateQueries(['modelMetrics', deviceId]);
  };

  return {
    consumptionData,
    predictions: predictions?.predictions || [],
    anomalies: predictions?.anomalies || [],
    metrics: metrics || {
      mse: 0,
      rmse: 0,
      mae: 0,
      accuracy: 0,
    },
    isLoading: isLoadingConsumption || isLoadingPredictions || isLoadingMetrics,
    error: consumptionError || predictionsError || metricsError,
    refreshData,
  };
}; 