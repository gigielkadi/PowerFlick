import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { format } from 'date-fns';
import { Box, Typography, useTheme } from '@mui/material';
import { PowerConsumptionData } from '../../types';

interface Props {
  data: PowerConsumptionData[];
  isLoading: boolean;
}

export const PowerConsumptionChart: React.FC<Props> = ({ data, isLoading }) => {
  const theme = useTheme();

  if (isLoading) {
    return (
      <Box
        sx={{
          height: 400,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Typography>Loading chart data...</Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ height: 400, width: '100%' }}>
      <ResponsiveContainer>
        <LineChart
          data={data}
          margin={{
            top: 20,
            right: 30,
            left: 20,
            bottom: 20,
          }}
        >
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="timestamp"
            tickFormatter={(timestamp) => format(new Date(timestamp), 'HH:mm')}
          />
          <YAxis
            label={{
              value: 'Power Consumption (kWh)',
              angle: -90,
              position: 'insideLeft',
            }}
          />
          <Tooltip
            labelFormatter={(timestamp) =>
              format(new Date(timestamp), 'MMM dd, HH:mm')
            }
            formatter={(value: number) => [`${value.toFixed(2)} kWh`]}
          />
          <Legend />
          <Line
            type="monotone"
            dataKey="consumption"
            name="Actual"
            stroke={theme.palette.primary.main}
            dot={false}
          />
          <Line
            type="monotone"
            dataKey="predictedConsumption"
            name="Predicted"
            stroke={theme.palette.secondary.main}
            strokeDasharray="5 5"
            dot={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </Box>
  );
}; 