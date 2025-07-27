import React from 'react';
import {
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Typography,
  Paper,
  useTheme,
} from '@mui/material';
import { Warning as WarningIcon } from '@mui/icons-material';
import { format } from 'date-fns';
import { PowerConsumptionAnomaly } from '../../types';

interface Props {
  anomalies: PowerConsumptionAnomaly[];
}

export const AnomalyList: React.FC<Props> = ({ anomalies }) => {
  const theme = useTheme();

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'high':
        return theme.palette.error.main;
      case 'medium':
        return theme.palette.warning.main;
      default:
        return theme.palette.info.main;
    }
  };

  if (anomalies.length === 0) {
    return (
      <Paper
        sx={{
          p: 3,
          textAlign: 'center',
          backgroundColor: theme.palette.background.default,
        }}
      >
        <Typography variant="body1" color="textSecondary">
          No anomalies detected
        </Typography>
      </Paper>
    );
  }

  return (
    <List>
      {anomalies.map((anomaly, index) => (
        <ListItem
          key={`${anomaly.timestamp}-${index}`}
          sx={{
            mb: 1,
            backgroundColor: theme.palette.background.paper,
            borderRadius: 1,
            boxShadow: 1,
          }}
        >
          <ListItemIcon>
            <WarningIcon sx={{ color: getSeverityColor(anomaly.severity) }} />
          </ListItemIcon>
          <ListItemText
            primary={
              <Typography variant="subtitle1">
                {anomaly.type === 'high_deviation'
                  ? 'Unusually High Consumption'
                  : 'Unusually Low Consumption'}
              </Typography>
            }
            secondary={
              <>
                <Typography variant="body2" color="textSecondary">
                  Deviation: {anomaly.deviationPercentage.toFixed(1)}%
                </Typography>
                <Typography variant="body2" color="textSecondary">
                  {format(new Date(anomaly.timestamp), 'MMM dd, HH:mm')}
                </Typography>
                <Typography variant="body2" color="textSecondary">
                  Value: {anomaly.value.toFixed(2)} kWh
                </Typography>
              </>
            }
          />
        </ListItem>
      ))}
    </List>
  );
}; 