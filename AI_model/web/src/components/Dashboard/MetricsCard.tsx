import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  useTheme,
  alpha,
} from '@mui/material';

interface Props {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  color?: string;
}

export const MetricsCard: React.FC<Props> = ({
  title,
  value,
  icon,
  color,
}) => {
  const theme = useTheme();
  const cardColor = color || theme.palette.primary.main;

  return (
    <Card
      sx={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        position: 'relative',
        overflow: 'hidden',
        '&:before': {
          content: '""',
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '4px',
          backgroundColor: cardColor,
        },
      }}
    >
      <CardContent sx={{ flexGrow: 1 }}>
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            mb: 2,
          }}
        >
          <Box
            sx={{
              p: 1,
              borderRadius: 1,
              backgroundColor: alpha(cardColor, 0.1),
              color: cardColor,
              mr: 2,
            }}
          >
            {icon}
          </Box>
          <Typography
            variant="subtitle2"
            color="textSecondary"
            sx={{ fontWeight: 500 }}
          >
            {title}
          </Typography>
        </Box>
        <Typography variant="h4" component="div" sx={{ fontWeight: 600 }}>
          {value}
        </Typography>
      </CardContent>
    </Card>
  );
}; 