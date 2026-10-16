import * as XLSX from 'xlsx';
import { Platform } from 'react-native';
import { ComplaintModel } from '../types/complaint';
import { LabModel, PcStatusModel } from '../types/lab';

export const excelService = {
  exportComplaintsToExcel(complaints: ComplaintModel[], filenamePrefix: string = 'Complaints_Report'): void {
    const rows = complaints.map((c) => {
      let dateStr = 'N/A';
      if (c.timestamp) {
        const d = c.timestamp.toDate ? c.timestamp.toDate() : new Date(c.timestamp);
        dateStr = d.toLocaleString();
      }

      return {
        'Ticket ID': c.complaintId.slice(0, 8),
        'Date & Time': dateStr,
        'Faculty Name': c.facultyName,
        'Lab Room': c.lab,
        Category: c.issueCategory,
        'Detected Issue': c.issue,
        Message: c.message,
        'Assigned Technician': c.assignedToName,
        Status: c.status,
        'Resolved By': c.resolvedByName || 'N/A',
        'Resolution Time (Mins)': c.timeTaken != null ? c.timeTaken : 'N/A',
      };
    });

    const worksheet = XLSX.utils.json_to_sheet(rows);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Complaints');

    const fileName = `${filenamePrefix}_${new Date().toISOString().slice(0, 10)}.xlsx`;

    if (Platform.OS === 'web') {
      XLSX.writeFile(workbook, fileName);
    } else {
      // In React Native mobile, generate base64
      try {
        const wbout = XLSX.write(workbook, { type: 'base64', bookType: 'xlsx' });
        console.log(`[Excel] Generated base64 for ${fileName}, size: ${wbout.length}`);
      } catch (err) {
        console.error('[Excel] Error generating mobile file:', err);
      }
    }
  },

  exportLabHardwareAudit(lab: LabModel, pcs: PcStatusModel[]): void {
    const rows = pcs.map((pc) => ({
      'Lab Name': lab.name,
      'Workstation ID': pc.pcId,
      Keyboard: pc.keyboardOk ? 'OK' : 'DEFECTIVE',
      Mouse: pc.mouseOk ? 'OK' : 'DEFECTIVE',
      Monitor: pc.ledOk ? 'OK' : 'DEFECTIVE',
      'CPU Power': pc.cpuWorking ? 'OK' : 'DEFECTIVE',
      'VGA/HDMI Cable': pc.vgaCableOk ? 'OK' : 'DEFECTIVE',
      'Power Cable': pc.powerCableOk ? 'OK' : 'DEFECTIVE',
      'LAN Internet Cable': pc.internetCableOk ? 'OK' : 'DEFECTIVE',
      RAM: pc.ram,
      Storage: pc.ssd,
      OS: pc.os,
      Notes: pc.notes || 'None',
    }));

    const worksheet = XLSX.utils.json_to_sheet(rows);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Hardware Audit');

    const fileName = `${lab.name.replace(/\s+/g, '_')}_Audit_${new Date().toISOString().slice(0, 10)}.xlsx`;

    if (Platform.OS === 'web') {
      XLSX.writeFile(workbook, fileName);
    }
  },
};
