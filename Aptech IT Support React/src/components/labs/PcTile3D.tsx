import React from 'react';
import { IsometricWorkstation, LabViewMode } from './IsometricWorkstation';
import { PcStatusModel } from '../../types/lab';

interface PcTile3DProps {
  pcId: string;
  status?: PcStatusModel;
  isActive?: boolean;
  isSelected?: boolean;
  isInstructor?: boolean;
  viewMode?: LabViewMode;
  onPress: () => void;
}

export const PcTile3D: React.FC<PcTile3DProps> = ({
  pcId,
  status,
  isActive = true,
  isSelected = false,
  isInstructor = false,
  viewMode = 'isometric',
  onPress,
}) => {
  return (
    <IsometricWorkstation
      pcId={pcId}
      status={status}
      isActive={isActive}
      isSelected={isSelected}
      isInstructor={isInstructor}
      viewMode={viewMode}
      onPress={onPress}
    />
  );
};
