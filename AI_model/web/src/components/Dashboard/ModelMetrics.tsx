import React from 'react';
import { Grid } from '@mui/material';
import {
  Timeline as TimelineIcon,
  TrendingUp as TrendingUpIcon,
  Warning as WarningIcon,
  Assessment as AssessmentIcon,
} from '@mui/icons-material';
import { MetricsCard } from './MetricsCard';
import { ModelMetrics as IModelMetrics } from '../../types';
import { useTheme } from '@mui/material/styles';

interface Props {
  metrics: IModelMetrics;
  anomalyCount: number;
  dataPoints: number;
}

export const ModelMetrics: React.FC<Props> = ({
  metrics,
  anomalyCount,
  dataPoints,
}) => {
  const theme = useTheme();

  return (
    <Grid container spacing={3}>
      <Grid item xs={12} sm={6} md={3}>
        <MetricsCard
          title="Model Accuracy"
          value={`${(metrics.accuracy * 100).toFixed(1)}%`}
          icon={<AssessmentIcon />}
          color={theme.palette.success.main}
        />
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <MetricsCard
          title="Active Alerts"
          value={anomalyCount}
          icon={<WarningIcon />}
          color={theme.palette.warning.main}
        />
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <MetricsCard
          title="Prediction Error"
          value={metrics.rmse.toFixed(3)}
          icon={<TrendingUpIcon />}
          color={theme.palette.info.main}
        />
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <MetricsCard
          title="Data Points"
          value={dataPoints}
          icon={<TimelineIcon />}
          color={theme.palette.primary.main}
        />
      </Grid>
    </Grid>
  );
}; 