export type Role = 'patient' | 'doctor'

export interface Patient {
  id: string
  name: string
  age: number
  gender: 'Male' | 'Female' | 'Other'
  condition: string
  medications: string[]
  doctor: string
  hospital: string
  medicalHistory: MedicalHistoryItem[]
  prescriptions: Prescription[]
  notes: Note[]
  menstrualData?: MenstrualData
}

export interface MedicalHistoryItem {
  id: string
  date: string
  description: string
  type: 'diagnosis' | 'procedure' | 'vaccination' | 'allergy'
}

export interface Prescription {
  id: string
  drugName: string
  dosage: string
  frequency: string
  instructions: string
  prescribedDate: string
  prescribedBy: string
}

export interface Note {
  id: string
  date: string
  content: string
  author: string
}

export interface MenstrualData {
  lastPeriodDate: string
  cycleLength: number
}

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export interface EmergencyCondition {
  id: string
  name: string
  icon: string
  steps: string[]
  urgencyLevel: 'critical' | 'high' | 'medium'
}

export interface ScannedPrescription {
  drugName: string
  dosage: string
  frequency: string
  instructions: string
  confidenceScore: number
}
