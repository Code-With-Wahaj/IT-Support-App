export interface LabModel {
  id: string;
  name: string;
  rows: number;
  columns: number;
  layoutType: string;
  assignedTo: string;
}

export interface PcStatusModel {
  pcId: string;
  keyboardOk: boolean;
  mouseOk: boolean;
  ledOk: boolean;
  vgaCableOk: boolean;
  powerCableOk: boolean;
  internetCableOk: boolean;
  cpuWorking: boolean;
  ram: string;
  ssd: string;
  os: string;
  notes: string;
}

export function isPcHealthy(pc: PcStatusModel): boolean {
  return (
    pc.keyboardOk &&
    pc.mouseOk &&
    pc.ledOk &&
    pc.cpuWorking &&
    pc.vgaCableOk &&
    pc.powerCableOk &&
    pc.internetCableOk &&
    Boolean(pc.ram && pc.ram.trim()) &&
    Boolean(pc.ssd && pc.ssd.trim()) &&
    Boolean(pc.os && pc.os.trim())
  );
}
